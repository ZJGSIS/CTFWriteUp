# 考点 
0. 难度:入坑
1. gif变成图片
2. 组合图片
3. 二维码反色

# maybe 给一下python代码？
```python
#encoding:utf-8
from PIL import Image
import PIL.ImageOps
# #读入图片
# image = Image.open('C:/Users/lala/Desktop/10yuan.png')
# #反转
# inverted_image = PIL.ImageOps.invert(image)
# #保存图片
# inverted_image.save('C:/Users/lala/Desktop/10yuan2.png')
image = Image.open('C:/Users/lala/Desktop/10yuan2.png')
print image.size
box1=[0,0,140,140]
box2=[0,140,140,280]
box3=[140,0,280,140]
box4=[140,140,280,280]
image1 = image.crop(box1)
image1.save('C:/Users/lala/Desktop/10yuan2_1.png')
image2 = image.crop(box2)
image2.save('C:/Users/lala/Desktop/10yuan2_2.png')
image3 = image.crop(box3)
image3.save('C:/Users/lala/Desktop/10yuan2_3.png')
image4 = image.crop(box4)
image4.save('C:/Users/lala/Desktop/10yuan2_4.png')
```
# by lala
