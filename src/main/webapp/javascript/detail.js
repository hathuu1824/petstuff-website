/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
document.addEventListener("DOMContentLoaded", () => {
  // ===== Helpers =====
  const $ = (s, r = document) => r.querySelector(s);
  const $$ = (s, r = document) => Array.from(r.querySelectorAll(s));
  const toVND = n => (n || 0).toLocaleString("vi-VN") + "₫";
  const int = v => parseInt(String(v).replace(/[^\d]/g, "")) || 0;
  const clamp = (v, a = 1, b = 100) => Math.min(Math.max(v, a), b);

  // ===== DOM =====
  const modal = $("#buyModal");
  const buyBtn = $(".buy-btn");
  const closeBtn = modal?.querySelector(".close-btn");
  const cancelBtn = modal?.querySelector(".cancel-btn");

  const details = $(".product-details");                 // chứa data-bank-* & (tùy) data-order-id
  const priceBox = $(".price");                          // có data-base-price & data-option-prices
  const optionBtns = $$(".option-btn");
  const qtyInput = $("#qtyInput");
  const qtyMinus = $(".qty-btn.minus");
  const qtyPlus = $(".qty-btn.plus");

  const shipEl = $("#modalShipFee");                     // data-ship="30000"
  const discountEl = $("#modalDiscount");                // data-discount="0"
  const totalEl = $("#modalTotalPrice");
  const modalQty = $("#modalQuantity");
  const methodSelect = $("#paymentMethod");

  const bankBox = $("#bankTransferBox");
  const qrImg = $("#vietqrImg");
  const bankLabel = $("#bankLabel");
  const accNameLabel = $("#accNameLabel");
  const accNoLabel = $("#accNoLabel");
  const transferAmountLabel = $("#transferAmountLabel");

  // ===== Data init =====
  const basePrice = int(priceBox?.dataset?.basePrice || 0);
  let optionPriceMap = {};
  try { optionPriceMap = JSON.parse(priceBox?.dataset?.optionPrices || "{}"); } catch(e){}

  const getActiveOptionName = () => $(".option-btn.active")?.dataset?.optionName || null;
  const unitPrice = () => {
    const name = getActiveOptionName();
    return name && optionPriceMap[name] != null ? int(optionPriceMap[name]) : basePrice;
  };

  const setPriceText = (n) => { if (priceBox) priceBox.textContent = toVND(n); };

  const buildVietQR = (amount) => {
    const bankCode = details?.dataset?.bankCode || "VCB";
    const accountNo = details?.dataset?.bankAccount || "";
    const accountName = details?.dataset?.accountName || "";
    const template = details?.dataset?.qrTemplate || "compact";

    bankLabel.textContent = bankCode;
    accNameLabel.textContent = accountName;
    accNoLabel.textContent = accountNo;
    transferAmountLabel.textContent = toVND(amount);

    const url = new URL(`https://api.vietqr.io/image/${bankCode}-${accountNo}-${template}.jpg`);
    url.searchParams.set("amount", amount);
    url.searchParams.set("accountName", accountName);
    qrImg.src = url.toString();
  };

  const recalcTotal = () => {
    const qty = clamp(int(qtyInput?.value || 1));
    if (qtyInput) qtyInput.value = qty;

    const ship = int(shipEl?.dataset?.ship || 0);
    const discount = int(discountEl?.dataset?.discount || 0);
    const total = unitPrice() * qty + ship - discount;

    if (modalQty) modalQty.textContent = qty;
    if (totalEl) totalEl.textContent = toVND(total);

    if (methodSelect?.value === "Bank") {
      bankBox.style.display = "block";
      buildVietQR(total);
    } else {
      bankBox.style.display = "none";
    }
  };

  // ===== Modal open/close =====
  const openModal = () => {
    if (!modal) return;
    modal.classList.add("show");
    modal.style.display = "block";
    document.body.style.overflow = "hidden";
    document.body.classList.add("modal-open"); // ẩn bong bóng bên phải

    setPriceText(unitPrice());
    recalcTotal();

    // Bắt đầu nghe SSE nếu có orderId
    const orderId = details?.dataset?.orderId;
    startPaymentListener(orderId);
  };

  const closeModal = () => {
    if (!modal) return;
    modal.classList.remove("show");
    modal.style.display = "none";
    document.body.style.overflow = "";
    document.body.classList.remove("modal-open");
  };

  // ===== Events =====
  buyBtn?.addEventListener("click", openModal);
  closeBtn?.addEventListener("click", closeModal);
  cancelBtn?.addEventListener("click", closeModal);
  window.addEventListener("click", (e) => { if (e.target === modal) closeModal(); });
  window.addEventListener("keydown", (e) => { if (e.key === "Escape" && modal?.classList.contains("show")) closeModal(); });

  optionBtns.forEach(btn => {
    btn.addEventListener("click", () => {
      optionBtns.forEach(b => b.classList.remove("active"));
      btn.classList.add("active");
      setPriceText(unitPrice());
      recalcTotal();
    });
  });

  qtyMinus?.addEventListener("click", () => { qtyInput.value = clamp(int(qtyInput.value) - 1); recalcTotal(); });
  qtyPlus?.addEventListener("click", () => { qtyInput.value = clamp(int(qtyInput.value) + 1); recalcTotal(); });
  qtyInput?.addEventListener("input", recalcTotal);
  qtyInput?.addEventListener("blur", recalcTotal);
  methodSelect?.addEventListener("change", recalcTotal);

  // ===== SSE: tự đóng khi thanh toán thành công =====
  function startPaymentListener(orderId) {
    if (!orderId || !window.EventSource) return;
    const es = new EventSource(`/payments/stream?orderId=${encodeURIComponent(orderId)}`);
    es.onmessage = (e) => {
      if (e.data === "PAID") {
        es.close();
        closeModal();
        // (tuỳ chọn) thông báo nhỏ
        // setTimeout(() => alert("Thanh toán thành công!"), 50);
      }
    };
    es.onerror = () => es.close();
  }

  // ===== Init lần đầu =====
  setPriceText(unitPrice());
  recalcTotal();
});
