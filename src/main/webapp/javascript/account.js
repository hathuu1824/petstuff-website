/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
document.addEventListener('DOMContentLoaded', function(){
    const input = document.getElementById('avatarInput');
    const img   = document.getElementById('avatarPreview');
    input.addEventListener('change', function(){
        const f = this.files && this.files[0];
        if(!f) return;
        if (f.size > 1024*1024){ // 1MB
            alert('Ảnh vượt quá 1MB');
            this.value = '';
            return;
        }
        const reader = new FileReader();
        reader.onload = e => img.src = e.target.result;
        reader.readAsDataURL(f);
    });
});