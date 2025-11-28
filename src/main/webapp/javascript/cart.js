// javascript/cart.js
document.addEventListener("DOMContentLoaded", () => {
  const $  = (s, r = document) => r.querySelector(s);
  const $$ = (s, r = document) => Array.from(r.querySelectorAll(s));
  const int  = v => parseInt(String(v).replace(/[^\d]/g, "")) || 0;
  const toVND = n => (n || 0).toLocaleString("vi-VN") + "đ";

  // Lấy context path từ body: <body data-ctx="<%=request.getContextPath()%>">
  const CTX = document.body.dataset.ctx || "";

  // Nếu trang được load lại bằng nút Back (từ bfcache) thì reload cho đồng bộ DB
  window.addEventListener("pageshow", (e) => {
    if (e.persisted) {
      window.location.reload();
    }
  });

  // ================= GIỎ HÀNG & TÓM TẮT =================
  const rows   = $$(".cart-item-row");
  const chkAll = $("#chkAll");

  const summaryLines = $$(".summary-line");
  const subtotalEl = summaryLines[0]?.querySelector("span:last-child strong"); // Tạm tính
  const discountEl = summaryLines[1]?.querySelector("span:last-child strong"); // Giảm giá
  const shipEl     = summaryLines[2]?.querySelector("span:last-child strong"); // Phí ship
  const savedEl    = summaryLines[3]?.querySelector("span:last-child strong"); // Tiết kiệm
  const totalEl    = $(".summary-total span:last-child");                      // Tổng tiền

  const baseSubtotal = subtotalEl ? int(subtotalEl.textContent) : 0;
  const baseDiscount = discountEl ? int(discountEl.textContent) : 0;
  const baseShip     = shipEl     ? int(shipEl.textContent)     : 0;
  const baseSaved    = savedEl    ? int(savedEl.textContent)    : 0;

  function recalcSummary() {
    let subtotal = 0;

    rows.forEach(row => {
      const cb = row.querySelector(".row-check");
      if (!cb || !cb.checked) return; // CHỈ tính các dòng đã tick

      const priceSpan = row.querySelector(".col-price span");
      const qtySpan   = row.querySelector(".col-qty .qty-value");

      const price = priceSpan ? int(priceSpan.textContent) : 0;
      const qty   = qtySpan   ? int(qtySpan.textContent)   : 1;

      subtotal += price * qty;
    });

    let discount = 0;
    let saved    = 0;
    if (baseSubtotal > 0 && subtotal > 0) {
      const ratio = subtotal / baseSubtotal;
      discount = Math.round(baseDiscount * ratio);
      saved    = Math.round(baseSaved * ratio);
    }

    const ship  = subtotal > 0 ? baseShip : 0;
    const total = subtotal + ship - discount;

    if (subtotalEl) subtotalEl.textContent = toVND(subtotal);
    if (discountEl) discountEl.textContent = toVND(discount);
    if (shipEl)     shipEl.textContent     = toVND(ship);
    if (savedEl)    savedEl.textContent    = toVND(saved);
    if (totalEl)    totalEl.textContent    = toVND(total);
  }

  // Checkbox từng dòng
  rows.forEach(row => {
    const cb = row.querySelector(".row-check");
    if (!cb) return;

    cb.addEventListener("change", () => {
      if (chkAll) {
        const allChecked = rows.length > 0 && rows.every(r => {
          const c = r.querySelector(".row-check");
          return c && c.checked;
        });
        chkAll.checked = allChecked;
      }
      recalcSummary();
    });
  });

  // Checkbox "Chọn tất cả"
  chkAll?.addEventListener("change", () => {
    const checked = chkAll.checked;
    rows.forEach(row => {
      const cb = row.querySelector(".row-check");
      if (cb) cb.checked = checked;
    });
    recalcSummary();
  });

  // Lần đầu vào: không tick gì -> 0 hết
  recalcSummary();

  // ================= MODAL THANH TOÁN TỪ GIỎ HÀNG =================
  const checkoutBtn      = $(".summary-buy-btn");

  const checkoutModal    = $("#cartCheckoutModal");
  const modalCloseIcon   = $("#cartModalClose");
  const modalCloseBtn    = $("#cartModalCloseBtn");
  const modalConfirmBtn  = $("#cartConfirmBtn");

  const modalItemCount   = $("#cartModalItemCount");
  const modalSubtotal    = $("#cartModalSubtotal");
  const modalShip        = $("#cartModalShip");
  const modalDiscount    = $("#cartModalDiscount");
  const modalTotal       = $("#cartModalTotal");

  const payMethodSelect  = $("#cartPaymentMethod");

  // QR
  const bankBox             = $("#cartBankTransferBox");
  const qrImg               = $("#cartVietqrImg");
  const bankLabel           = $("#cartBankLabel");
  const accNameLabel        = $("#cartAccNameLabel");
  const accNoLabel          = $("#cartAccNoLabel");
  const transferAmountLabel = $("#cartTransferAmountLabel");

  // === Thông tin tài khoản thật (giống trang chi tiết) ===
  const BANK_CODE    = "CAKE";
  const BANK_ACCOUNT = "0353086897";
  const ACCOUNT_NAME = "KIEU HA THU";

  function buildVietQR(amount) {
    if (!qrImg) return;

    // Cập nhật text bên cạnh QR
    bankLabel.textContent           = BANK_CODE;
    accNameLabel.textContent        = ACCOUNT_NAME;
    accNoLabel.textContent          = BANK_ACCOUNT;
    transferAmountLabel.textContent = toVND(amount);

    const amt = Math.max(0, Math.round(Number(amount) || 0));
    const addInfo = encodeURIComponent("Thanh toan gio hang PetStuff");

    // Dùng img.vietqr.io giống chi tiết sản phẩm
    const url = new URL(`https://img.vietqr.io/image/${BANK_CODE}-${BANK_ACCOUNT}-compact.png`);
    url.searchParams.set("amount", amt);
    url.searchParams.set("addInfo", addInfo);

    qrImg.src = url.toString();
  }

  function openCartModal() {
    if (!checkoutModal) return;
    checkoutModal.classList.add("show");
    checkoutModal.style.display = "block";
    document.body.classList.add("modal-open");
    document.body.style.overflow = "hidden";
  }

  function closeCartModal() {
    if (!checkoutModal) return;
    checkoutModal.classList.remove("show");
    checkoutModal.style.display = "none";
    document.body.classList.remove("modal-open");
    document.body.style.overflow = "";
  }

  function getSelectedRows() {
    return rows.filter(row => {
      const cb = row.querySelector(".row-check");
      return cb && cb.checked;
    });
  }

  function getSelectedCartIds() {
    const ids = [];
    getSelectedRows().forEach(row => {
      const cb = row.querySelector(".row-check");
      if (cb && cb.value) {
        ids.push(cb.value);
      }
    });
    return ids;
  }

  // Khi bấm nút MUA HÀNG -> mở modal
  checkoutBtn?.addEventListener("click", e => {
    e.preventDefault();

    const selectedRows = getSelectedRows();

    if (selectedRows.length === 0) {
      alert("Vui lòng chọn ít nhất một sản phẩm để thanh toán.");
      return;
    }

    // Cập nhật tóm tắt cho chắc
    recalcSummary();

    let itemCount = 0;
    selectedRows.forEach(row => {
      const qtySpan = row.querySelector(".col-qty .qty-value");
      itemCount += qtySpan ? int(qtySpan.textContent) : 1;
    });

    const subtotal = subtotalEl ? int(subtotalEl.textContent) : 0;
    const discount = discountEl ? int(discountEl.textContent) : 0;
    const ship     = shipEl     ? int(shipEl.textContent)     : 0;
    const total    = totalEl    ? int(totalEl.textContent)    : 0;

    if (modalItemCount) modalItemCount.textContent = String(itemCount);
    if (modalSubtotal)  modalSubtotal.textContent  = toVND(subtotal);
    if (modalShip) {
      modalShip.dataset.ship = ship;
      modalShip.textContent  = toVND(ship);
    }
    if (modalDiscount) {
      modalDiscount.dataset.discount = discount;
      modalDiscount.textContent      = toVND(discount);
    }
    if (modalTotal) modalTotal.textContent = toVND(total);

    // Nếu đang chọn BANK thì show QR
    if (payMethodSelect?.value === "BANK") {
      if (bankBox) bankBox.style.display = "block";
      buildVietQR(total);
    } else if (bankBox) {
      bankBox.style.display = "none";
    }

    openCartModal();
  });

  // ===== GỌI /order ĐỂ TẠO ĐƠN HÀNG (COD + BANK) =====
  function createCartOrder() {
    const selectedRows = getSelectedRows();

    if (!selectedRows.length) {
      throw new Error("Vui lòng chọn ít nhất một sản phẩm.");
    }

    // Lấy masp của dòng đầu tiên (cách làm cũ)
    const firstRow = selectedRows[0];
    const maspAttr =
      firstRow.dataset.productId ||
      firstRow.dataset.masp ||
      firstRow.getAttribute("data-product-id") ||
      firstRow.getAttribute("data-masp");

    if (!maspAttr || !maspAttr.trim()) {
      throw new Error("Không xác định được mã sản phẩm (data-masp / data-product-id).");
    }

    const masp = maspAttr.trim();

    // Tổng số lượng của các dòng được chọn
    let totalQty = 0;
    selectedRows.forEach(row => {
      const qtySpan = row.querySelector(".col-qty .qty-value");
      totalQty += qtySpan ? int(qtySpan.textContent) : 1;
    });

    const subtotal = subtotalEl ? int(subtotalEl.textContent) : 0;
    const discount = discountEl ? int(discountEl.textContent) : 0;
    const ship     = shipEl     ? int(shipEl.textContent)     : 0;
    const total    = totalEl    ? int(totalEl.textContent)    : 0;

    const unitPrice = totalQty > 0 ? Math.round(subtotal / totalQty) : 0;

    // Method: COD / BANK (giống select)
    const method    = payMethodSelect?.value === "BANK" ? "BANK" : "COD";

    const params = new URLSearchParams();
    params.append("masp",       masp);
    params.append("soluong",    String(totalQty));
    params.append("phisp",      String(unitPrice));
    params.append("phiship",    String(ship));
    params.append("giamgia",    String(discount));
    params.append("phuongthuc", method);
    params.append("tongtien",   String(total)); // gửi thêm tổng tiền

    const orderUrl = CTX + "/order";

    return fetch(orderUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
      },
      body: params.toString()
    }).then(async res => {
      let data = null;
      try { data = await res.json(); } catch {}
      if (!res.ok || !data || data.status !== "success") {
        const msg = data && data.message
          ? data.message
          : "Không thể tạo đơn hàng, vui lòng thử lại.";
        throw new Error(msg);
      }
      return data;   // {status: "success", orderId: ...}
    });
  }

  // ===== Sau khi tạo đơn, gọi /cart?action=checkout để xóa các cartId được chọn khỏi DB =====
  function checkoutSelectedRows() {
    const ids = getSelectedCartIds();
    if (!ids.length) {
      return Promise.resolve(); // Không có gì để xóa
    }

    const params = new URLSearchParams();
    params.append("action", "checkout");
    ids.forEach(id => params.append("selected", id));

    const url = CTX + "/cart";

    return fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
      },
      body: params.toString()
    }).then(res => {
      if (!res.ok) {
        throw new Error("Không thể cập nhật giỏ hàng sau khi mua.");
      }
    });
  }

  // Đổi phương thức thanh toán trong modal
  payMethodSelect?.addEventListener("change", () => {
    const total = modalTotal ? int(modalTotal.textContent) : 0;
    if (payMethodSelect.value === "BANK") {
      if (bankBox) bankBox.style.display = "block";
      buildVietQR(total);
    } else if (bankBox) {
      bankBox.style.display = "none";
    }
  });

  // Đóng modal
  modalCloseIcon?.addEventListener("click", closeCartModal);
  modalCloseBtn?.addEventListener("click", closeCartModal);
  window.addEventListener("click", e => {
    if (e.target === checkoutModal) closeCartModal();
  });

  // Xác nhận -> tạo đơn -> xóa hàng đã chọn trong DB -> reload giỏ
  modalConfirmBtn?.addEventListener("click", e => {
    e.preventDefault();
    createCartOrder()
      .then(data => {
        return checkoutSelectedRows().then(() => data);
      })
      .then(data => {
        closeCartModal();
        alert("Đặt hàng thành công! Mã đơn: " + data.orderId);
        // Reload lại giỏ từ servlet để luôn khớp DB
        window.location.href = CTX + "/cart";
      })
      .catch(err => {
        alert(err.message || "Không thể tạo đơn hàng, vui lòng thử lại.");
      });
  });

  // ================= USER MENU DROPDOWN =================
  const userMenu      = document.querySelector(".user-menu");
  const userToggle    = document.querySelector(".user-toggle");
  const dropdownItems = $$(".has-dd");

  if (userMenu && userToggle) {
    userToggle.addEventListener("click", e => {
      e.preventDefault();
      e.stopPropagation();
      userMenu.classList.toggle("open");
    });
  }

  document.addEventListener("click", e => {
    dropdownItems.forEach(li => li.classList.remove("open"));
    if (userMenu && !userMenu.contains(e.target)) {
      userMenu.classList.remove("open");
    }
  });

  window.addEventListener("keydown", e => {
    if (e.key === "Escape") {
      dropdownItems.forEach(li => li.classList.remove("open"));
      if (userMenu) userMenu.classList.remove("open");
      closeCartModal();
    }
  });
});
