/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
(function(){
    const scroller = document.getElementById('promoSlider');
    if(!scroller) return;
    const step = scroller.clientWidth * 0.9;

    document.querySelector('.p-prev')?.addEventListener('click', () => {
      scroller.scrollBy({ left: -step, behavior: 'smooth' });
    });
    document.querySelector('.p-next')?.addEventListener('click', () => {
      scroller.scrollBy({ left: step, behavior: 'smooth' });
    });
})();

