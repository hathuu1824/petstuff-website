/* 
 * JS chi tiết sản phẩm + mua ngay + thêm vào giỏ hàng
 */
document.addEventListener("DOMContentLoaded", () => {
  const $  = (s, r = document) => r.querySelector(s);
  const $$ = (s, r = document) => Array.from(r.querySelectorAll(s));
  const toVND = n => (n || 0).toLocaleString("vi-VN") + "₫";
  const int   = v => parseInt(String(v).replace(/[^\d]/g, "")) || 0;
  const clamp = (v, a = 1, b = 100) => Math.min(Math.max(v, a), b);

  const body         = document.body;
  const IS_LOGGED_IN = body.dataset.loggedIn === "true";
  const CTX          = body.dataset.ctx || "";

  const modal          = $("#buyModal");
  const buyBtn         = $("#buyNowBtn");
  const cartBtn        = $("#addToCartBtn");
  const closeBtn       = $(".close-btn");
  const closeModalBtn  = $("#closeModalBtn");
  const confirmBtn     = $("#confirmOrderBtn");

  const details        = $(".product-details");
  const priceBox       = $(".price");
  const optionBtns     = $$(".option-btn");
  const qtyInput       = $("#qtyInput");
  const qtyMinus       = $(".qty-btn.minus");
  const qtyPlus        = $(".qty-btn.plus");

  const shipEl         = $("#modalShipFee");
  const discountEl     = $("#modalDiscount");
  const totalEl        = $("#modalTotalPrice");
  const modalQty       = $("#modalQuantity");
  const modalUnitPrice = $("#modalUnitPrice");
  const methodSelect   = $("#paymentMethod");

  const bankBox             = $("#bankTransferBox");
  const qrImg               = $("#vietqrImg");
  const bankLabel           = $("#bankLabel");
  const accNameLabel        = $("#accNameLabel");
  const accNoLabel          = $("#accNoLabel");
  const transferAmountLabel = $("#transferAmountLabel");

  const addCartForm   = $("#addCartForm");
  const loaiHidden    = $("#loaiIdInput");
  const qtyHidden     = $("#qtyHiddenInput");

  const loginPopup     = $("#loginPopup");
  const popupCancel    = $("#popupCancel");
  const popupOK        = $("#popupOK");

  // Popup tạo đơn hàng thành công
  const orderSuccessPopup = $("#orderSuccessPopup");
  const successOrderIdEl  = $("#successOrderId");
  const orderStayBtn      = $("#orderStayBtn");
  const orderViewBtn      = $("#orderViewBtn");

  const showLoginPopup = () => {
    if (loginPopup) loginPopup.style.display = "flex";
  };
  const hideLoginPopup = () => {
    if (loginPopup) loginPopup.style.display = "none";
  };

  popupCancel?.addEventListener("click", e => {
    e.preventDefault();
    hideLoginPopup();
  });

  popupOK?.addEventListener("click", e => {
    e.preventDefault();
    window.location.href = CTX + "/login.jsp";
  });

  // ====== GIÁ KHUYẾN MÃI (SALE) ======
  const basePrice = int(priceBox?.dataset?.basePrice || 0); // luôn là giá KM
  let optionPriceMap = {};
  try {
    optionPriceMap = JSON.parse(priceBox?.dataset?.optionPrices || "{}");
  } catch {
    optionPriceMap = {};
  }

  const getActiveOptionBtn = () =>
    $(".option-btn.active") || null;

  const getActiveOptionName = () =>
    getActiveOptionBtn()?.dataset?.optionName || null;

  // Giá 1 sản phẩm (ưu tiên data-price của option, sau đó tới map / basePrice)
  const unitPrice = () => {
    const activeBtn = getActiveOptionBtn();
    if (activeBtn && activeBtn.dataset.price) {
      return int(activeBtn.dataset.price);
    }
    const name = getActiveOptionName();
    if (name && optionPriceMap[name] != null) {
      return int(optionPriceMap[name]);
    }
    return basePrice;
  };

  const priceCurrentEl = priceBox ? priceBox.querySelector(".price-current") : null;
  const setPriceText = n => {
    if (priceCurrentEl) priceCurrentEl.textContent = toVND(n);
  };

  // ====== TẠO VIETQR – ưu tiên data trên product-details, fallback body ======
  const buildVietQR = amount => {
    if (!qrImg || !bankLabel || !accNameLabel || !accNoLabel || !transferAmountLabel) return;

    // Lấy thông tin từ data-attribute (ưu tiên trong .product-details)
    const bankCode =
      details?.dataset?.bankCode ||
      body.dataset.bankCode ||
      "CAKE";

    const accountNo =
      details?.dataset?.bankAccount ||
      body.dataset.bankAccount ||
      "";

    const accountName =
      details?.dataset?.accountName ||
      body.dataset.accountName ||
      details?.dataset?.bankName ||
      body.dataset.bankName ||
      "";

    const template =
      details?.dataset?.qrTemplate ||
      body.dataset.qrTemplate ||
      "compact";

    // Cập nhật thông tin hiển thị bên cạnh QR
    bankLabel.textContent           = bankCode;
    accNameLabel.textContent        = accountName;
    accNoLabel.textContent          = accountNo;
    transferAmountLabel.textContent = toVND(amount);

    if (!bankCode || !accountNo) {
      qrImg.removeAttribute("src");
      return;
    }

    // amount phải là số nguyên, không có dấu chấm phẩy
    const amt = Math.max(0, Math.round(Number(amount) || 0));

    // Nội dung chuyển khoản (mô tả đơn hàng)
    const productName = details?.dataset?.productName || "PetStuff";
    const addInfo = encodeURIComponent(`Thanh toan ${productName}`);

    // VietQR official: img.vietqr.io
    const url = new URL(`https://img.vietqr.io/image/${bankCode}-${accountNo}-${template}.png`);
    url.searchParams.set("amount", amt);
    url.searchParams.set("addInfo", addInfo);
    if (accountName) {
      url.searchParams.set("accountName", accountName);
    }

    qrImg.src = url.toString();
  };

  // ====== TÍNH TỔNG & GỌI QR ======
  let currentTotal = 0;
  const recalcTotal = () => {
    const qty = clamp(int(qtyInput?.value || 1));
    if (qtyInput) qtyInput.value = qty;

    const price    = unitPrice(); // đơn giá (giá KM)
    const ship     = int(shipEl?.dataset?.ship         || 0);
    const discount = int(discountEl?.dataset?.discount || 0);
    const total    = price * qty + ship - discount;

    currentTotal = total;

    if (modalQty)       modalQty.textContent       = qty;
    if (modalUnitPrice) modalUnitPrice.textContent = toVND(price);
    if (totalEl)        totalEl.textContent        = toVND(total);

    if (methodSelect?.value === "Bank") {
      if (bankBox) bankBox.style.display = "block";
      buildVietQR(total);
    } else if (bankBox) {
      bankBox.style.display = "none";
    }
  };

  const openModal = () => {
    if (!modal) return;
    modal.classList.add("show");
    modal.style.display = "block";
    document.body.style.overflow = "hidden";
    document.body.classList.add("modal-open");
    setPriceText(unitPrice());
    recalcTotal();
  };

  const closeModal = () => {
    if (!modal) return;
    modal.classList.remove("show");
    modal.style.display = "none";
    document.body.style.overflow = "";
    document.body.classList.remove("modal-open");
  };

  buyBtn?.addEventListener("click", e => {
    e.preventDefault();
    if (!IS_LOGGED_IN) {
      showLoginPopup();
      return;
    }
    openModal();
  });

  // Thêm vào giỏ (form submit)
  cartBtn?.addEventListener("click", e => {
    if (!IS_LOGGED_IN) {
      e.preventDefault();
      showLoginPopup();
      return;
    }

    if (!getActiveOptionBtn() && optionBtns.length > 0) {
      optionBtns[0].classList.add("active");
    }

    const activeBtn = getActiveOptionBtn();
    if (activeBtn && loaiHidden) {
      const optId = activeBtn.dataset.optionId;
      if (optId) loaiHidden.value = optId;
    }

    let qty = clamp(int(qtyInput?.value || 1));
    if (qtyInput) qtyInput.value = qty;
    if (qtyHidden) qtyHidden.value = String(qty);

    // browser tự submit form
  });

  closeBtn?.addEventListener("click", closeModal);
  closeModalBtn?.addEventListener("click", closeModal);

  window.addEventListener("click", e => {
    if (e.target === modal) closeModal();
  });

  window.addEventListener("keydown", e => {
    if (e.key === "Escape" && modal?.classList.contains("show")) {
      closeModal();
    }
  });

  optionBtns.forEach(btn => {
    btn.addEventListener("click", () => {
      optionBtns.forEach(b => b.classList.remove("active"));
      btn.classList.add("active");
      setPriceText(unitPrice());
      recalcTotal();

      const optId = btn.dataset.optionId;
      if (optId && loaiHidden) loaiHidden.value = optId;
    });
  });

  qtyMinus?.addEventListener("click", () => {
    qtyInput.value = clamp(int(qtyInput.value) - 1);
    recalcTotal();
  });

  qtyPlus?.addEventListener("click", () => {
    qtyInput.value = clamp(int(qtyInput.value) + 1);
    recalcTotal();
  });

  qtyInput?.addEventListener("input", recalcTotal);
  qtyInput?.addEventListener("blur", recalcTotal);
  methodSelect?.addEventListener("change", recalcTotal);

    const createOrder = () => {
    const productId = details?.dataset?.productId;
    const orderUrl  = details?.dataset?.orderUrl || (CTX + "/order");
    if (!productId) {
      alert("Không xác định được sản phẩm.");
      return;
    }

    const qty      = clamp(int(qtyInput?.value || 1));
    const ship     = int(shipEl?.dataset?.ship         || 0);
    const discount = int(discountEl?.dataset?.discount || 0);
    const price    = unitPrice(); // GIÁ KHUYẾN MÃI
    const total    = price * qty + ship - discount;
    const method   = methodSelect?.value === "Bank" ? "BANK" : "COD";

    const params = new URLSearchParams();
    params.append("masp",      productId);
    params.append("soluong",   String(qty));
    params.append("phisp",     String(price));    // đơn giá (sale)
    params.append("phiship",   String(ship));
    params.append("giamgia",   String(discount));
    params.append("tongtien",  String(total));
    params.append("phuongthuc", method);          // 'BANK' hoặc 'COD'

    fetch(orderUrl, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
      body: params.toString()
    })
      .then(async res => {
        let data = null;
        try { data = await res.json(); } catch {}
        if (!res.ok || !data || data.status !== "success") {
          const msg = data && data.message
            ? data.message
            : "Không thể tạo đơn hàng, vui lòng thử lại sau.";
          throw new Error(msg);
        }
        return data;
      })
      .then(data => {
        closeModal();
        if (orderSuccessPopup) {
          successOrderIdEl.textContent = data.orderId || "";
          orderSuccessPopup.style.display = "flex";
        } else {
          alert("Đặt hàng thành công!");
        }
      })
      .catch(err => {
        console.error(err);
        alert(err.message || "Không thể tạo đơn hàng, vui lòng thử lại sau.");
      });
  };

  confirmBtn?.addEventListener("click", e => {
    e.preventDefault();
    if (!IS_LOGGED_IN) {
      showLoginPopup();
      return;
    }
    createOrder();
  });

  // Init
  setPriceText(unitPrice());
  recalcTotal();

  // Popup tạo đơn hàng thành công
  orderStayBtn?.addEventListener("click", () => {
    if (orderSuccessPopup) orderSuccessPopup.style.display = "none";
  });

  orderViewBtn?.addEventListener("click", () => {
    window.location.href = CTX + "/donhang";
  });

  // Popup user
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
    }
  });
});
