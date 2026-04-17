import cv2
import numpy as np
import matplotlib.pyplot as plt

# قراءة الصورة
image = cv2.imread('image.jpg')

if image is None:
    print("خطأ: لم يتم العثور على الصورة!")
    exit()

# تحويل إلى RGB وGrayscale
image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

# قيمة العتبة
threshold_value = 127
max_value = 255

# ========================================
# Simple Thresholding
# ========================================

# Binary: قيمة > عتبة → 255، وإلا → 0
_, binary = cv2.threshold(gray, threshold_value, max_value, cv2.THRESH_BINARY)

# Binary Inverse: عكس Binary
_, binary_inv = cv2.threshold(gray, threshold_value, max_value, cv2.THRESH_BINARY_INV)

# Truncate: قيمة > عتبة → تساوي العتبة، وإلا → تبقى كما هي
_, trunc = cv2.threshold(gray, threshold_value, max_value, cv2.THRESH_TRUNC)

# To Zero: قيمة > عتبة → تبقى، وإلا → 0
_, tozero = cv2.threshold(gray, threshold_value, max_value, cv2.THRESH_TOZERO)

# To Zero Inverse: قيمة > عتبة → 0، وإلا → تبقى
_, tozero_inv = cv2.threshold(gray, threshold_value, max_value, cv2.THRESH_TOZERO_INV)

# ========================================
# Adaptive Thresholding
# ========================================

# العتبة تتغير حسب كل منطقة في الصورة
adaptive_mean = cv2.adaptiveThreshold(gray, 255, cv2.ADAPTIVE_THRESH_MEAN_C, 
                                      cv2.THRESH_BINARY, 11, 2)

adaptive_gaussian = cv2.adaptiveThreshold(gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, 
                                          cv2.THRESH_BINARY, 11, 2)

# ========================================
# Otsu's Thresholding
# ========================================

# تحسب العتبة المثلى تلقائياً
otsu_threshold, otsu = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
print(f"العتبة المحسوبة بطريقة Otsu: {otsu_threshold:.2f}")

# ========================================
# عرض النتائج
# ========================================

plt.figure(figsize=(15, 12))

plt.subplot(3, 3, 1)
plt.imshow(image_rgb)
plt.title('الصورة الأصلية')
plt.axis('off')

plt.subplot(3, 3, 2)
plt.imshow(gray, cmap='gray')
plt.title('Grayscale')
plt.axis('off')

plt.subplot(3, 3, 3)
plt.imshow(binary, cmap='gray')
plt.title(f'Binary (threshold={threshold_value})')
plt.axis('off')

plt.subplot(3, 3, 4)
plt.imshow(binary_inv, cmap='gray')
plt.title('Binary Inverse')
plt.axis('off')

plt.subplot(3, 3, 5)
plt.imshow(trunc, cmap='gray')
plt.title('Truncate')
plt.axis('off')

plt.subplot(3, 3, 6)
plt.imshow(tozero, cmap='gray')
plt.title('To Zero')
plt.axis('off')

plt.subplot(3, 3, 7)
plt.imshow(tozero_inv, cmap='gray')
plt.title('To Zero Inverse')
plt.axis('off')

plt.subplot(3, 3, 8)
plt.imshow(adaptive_mean, cmap='gray')
plt.title('Adaptive Mean')
plt.axis('off')

plt.subplot(3, 3, 9)
plt.imshow(otsu, cmap='gray')
plt.title(f'Otsu (threshold={otsu_threshold:.1f})')
plt.axis('off')

plt.tight_layout()
plt.savefig('thresholding_results.png', dpi=150)
plt.show()

# حفظ الصور
cv2.imwrite('output_binary.jpg', binary)
cv2.imwrite('output_otsu.jpg', otsu)
cv2.imwrite('output_adaptive.jpg', adaptive_mean)

print("تم حفظ الصور بنجاح!")

# ========================================
# مثال تفاعلي مع Trackbar (اختياري)
# ========================================

def apply_threshold(x):
    thresh_value = cv2.getTrackbarPos('Threshold', 'Interactive')
    _, result = cv2.threshold(gray, thresh_value, 255, cv2.THRESH_BINARY)
    cv2.imshow('Interactive', result)

# لتفعيل الوضع التفاعلي، أزل التعليق عن الكود التالي:
"""
cv2.namedWindow('Interactive')
cv2.createTrackbar('Threshold', 'Interactive', 127, 255, apply_threshold)
apply_threshold(127)

while True:
    if cv2.waitKey(1) & 0xFF == 27:  # اضغط ESC للخروج
        break

cv2.destroyAllWindows()
"""