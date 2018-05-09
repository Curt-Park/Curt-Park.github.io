---
layout: post
title: "Faster R-CNN"
description: "Paper study of Faster R-CNN published in Jan. 2016"
date: 2017-03-17
tags: [object detection]
comments: true
share: true
use_math: false
---

![]({{ site.url }}/images/faster_rcnn/Title.png "Title"){: .aligncenter}

# Introduction

Fast R-CNN은 R-CNN의 복잡한 training/test pipeline을 통합함으로써 눈에띄는 성능향상(속도, 정확도)을 가져왔지만, 
Real-time object detector에 한 발짝 더 다가가기에는 여전히 속도면에서 아쉬운 부분이 남아있었다.

이 논문의 주요 논점은, Fast R-CNN에서 가장 큰 계산부하를 차지하는 region proposal 생성을 새로운 방식으로 대체하고, 
이를 모델 내부로 통합시키는 것이다. 이에 고안된 것이 바로 아래 그림의 **Region Proposal Networks**다. (이하 **RPNs**)
![]({{ site.url }}/images/faster_rcnn/Figure2.png "Figure2"){: .aligncenter}

# Region Proposal Networks

RPNs은 image를 입력받아 사각형 형태의 Object Proposal과 Objectness Score를 출력해주는 역할을 한다. 
이는 Fully convolutional network 형태이며, Fast R-CNN과 convolutional layers를 공유하게끔 디자인되어있다. 
다음으로는 RPNs의 주요 특징들을 살펴보도록 하자.

#### Anchor Box
Anchor box는 sliding window의 각 위치에서 Bounding Box의 후보로 사용되는 상자다.
이는 기존에 두루 사용되던 Image/Feature pyramids와 Multiple-scaled sliding window와 다음과 같은 차이를 보인다.
![]({{ site.url }}/images/faster_rcnn/Figure1.png "Figure1"){: .aligncenter}

직관적으로 설명하자면, 동일한 크기의 sliding window를 이동시키며 window의 위치를 중심으로 사전에 정의된 다양한 비율/크기의 anchor box들을 적용하여 feature를 추출하는 것이다.
이는 image/feature pyramids처럼 image 크기를 조정할 필요가 없으며, multiple-scaled sliding window처럼 filter 크기를 변경할 필요도 없으므로 계산효율이 높은 방식이라 할 수 있다.
논문에서는 3가지 크기와 3가지 비율의, 총 9개의 anchor box들을 사용하였다.

#### Labeling to each anchor (Object? or Backgound?)
특정 anchor에 positive label이 할당되는 데에는 다음과 같은 기준이 있다.

1. 가장 높은 Intersection-over-Union(IoU)을 가지고 있는 anchor.
2. IoU > 0.7 을 만족하는 anchor.

2번 기준만으로는 아주 드물게 Object를 잡아내지 못하는 경우가 있어서 후에 1번 기준이 추가되었다.

반면, IoU가 0.3보다 낮은 anchor에 대해선 non-positive anchor로 간주한다.

#### Computation Process
![]({{ site.url }}/images/faster_rcnn/Figure3.png "Figure3"){: .aligncenter}

1. Shared CNN에서 convolutional feature map(14X14X512 for VGG)을 입력받는다. 여기서는 Shared CNN으로 VGG가 사용되었다고 가정한다. 
(Figure3는 ZF Net의 예시 - 256d)
2. Intermediate Layer: 3X3 filter with 1 stride and 1 padding을 512개 적용하여 14X14X512의 아웃풋을 얻는다. 
3. Output layer
- cls layer: 1X1 filter with 1 stride and 0 padding을 9*2(=18)개 적용하여 14X14X9X2의 이웃풋을 얻는다. 
여기서 filter의 개수는, anchor box의 개수(9개) * score의 개수(2개: object? / non-object?)로 결정된다.
- reg layer: 1X1 filter with 1 stride and 0 padding을 9*4(=36)개 적용하여 14X14X9X4의 아웃풋을 얻는다. 
여기서 filter의 개수는, anchor box의 개수(9개) * 각 box의 좌표 표시를 위한 데이터의 개수(4개: dx, dy, w, h)로 결정된다. ([코드1](https://github.com/rbgirshick/py-faster-rcnn/blob/96dc9f1dea3087474d6da5a98879072901ee9bf9/lib/rpn/proposal_layer.py#L73): 예측된 bounding box에 대한 정보, [코드2](https://github.com/rbgirshick/py-faster-rcnn/blob/96dc9f1dea3087474d6da5a98879072901ee9bf9/lib/fast_rcnn/bbox_transform.py#L30): 사전정의된 anchor box의 정보에 예측된 bounding box에 대한 정보를 반영)

주목할 점은, output layer에서 사용되는 파라미터의 개수다. 
VGG-16을 기준으로 했을때 약 2.8 X 10^4개의 파라미터를 갖게 되는데(512 X (4+2) X 9), 다른 모델들의 output layer 파라미터 개수 -가령, GoogleNet in MultiBox의 경우 약 6.1 X 10^6- 보다 훨씬 적은 것을 알 수 있다. 
이를 통해 small dataset에 대한 overfitting의 위험도가 상대적으로 낮으리라 예상할 수 있다.

#### Loss Function
Loss Function은 아래 그림과 같다.
![]({{ site.url }}/images/faster_rcnn/LossFunction.png "LossFunction"){: .aligncenter}

* **pi**: Predicted probability of anchor
* __pi*__: Ground-truth label (1: anchor is positive, 0: anchor is negative)
* **lambda**: Balancing parameter. Ncls와 Nreg 차이로 발생하는 불균형을 방지하기 위해 사용된다. cls에 대한 mini-batch의 크기가 256(=Ncls)이고, 이미지 내부에서 사용된 모든 anchor의 location이 약 2,400(=Nreg)라 하면 lamda 값은 10 정도로 설정한다.
* **ti**: Predicted Bounding box
* __ti*__: Ground-truth box

Bounding box regression 과정(Lreg)에서는 4개의 coordinate들에 대해 다음과 같은 연산을 취한 후,
![]({{ site.url }}/images/faster_rcnn/BBRegression.png "BBRegression"){: .aligncenter}

Smooth L1 loss function(아래)을 통해 Loss를 계산한다.
![]({{ site.url }}/images/faster_rcnn/SmoothL1.png "SmoothL1"){: .aligncenter}

R-CNN / Fast R-CNN에서는 모든 Region of Interest가 그 크기와 비율에 상관없이 weight를 공유했던 것에 비해, 
이 anchor 방식에서는 k개의 anchor에 상응하는 k개의 regressor를 갖게된다.

# Training RPNs

* end-to-end로 back-propagation 사용.
* Stochastic gradient descent
* 한 이미지당 랜덤하게 256개의 sample anchor들을 사용. 이때, Sample은 positive anchor:negative anchor = 1:1 비율로 섞는다. 혹시 positive anchor의 개수가 128개보다 낮을 경우, 빈 자리는 negative sample로 채운다. 이미지 내에 negative sample이 positive sample보다 훨씬 많으므로 이런 작업이 필요하다.
* 모든 weight는 랜덤하게 초기화. (from a zero-mean Gaussian distribution with standard deviation 0.01)
* ImageNet classification으로 fine-tuning (ZF는 모든 layer들, VGG는 conv3_1포함 그 위의 layer들만. Fast R-CNN 논문 4.5절 참고.)
* Learning Rate: 0.001 (처음 60k의 mini-batches), 0.0001 (다음 20k의 mini-batches)
* Momentum: 0.9
* Weight decay: 0.0005

# Sharing Features for RPN and Fast R-CNN

논문상의 실험에서는 4-step alternating training 방식을 사용하였다.

**4-step alternating training**

    1. Train RPNs
    2. Train Fast R-CNN using the proposals from RPNs
    3. Fix the shared convolutional layers and fine-tune unique layers to RPN
    4. Fine-tune unique layers to Fast R-CNN

모델 구조가 Fast R-CNN에서 개선된 것치고 Training 절차가 다소 지저분하다.
이 문제는 논문 출판 이후, [Joint training](https://www.dropbox.com/s/xtr4yd4i5e0vw8g/iccv15_tutorial_training_rbg.pdf) 방식을 도입하여 개선되었다고 한다. (약 1.5배의 성능향상)

# Experiments

![]({{ site.url }}/images/faster_rcnn/Figure4.png "Figure4"){: .aligncenter}
Figure4: IoU threshold를 조절했을때 Recall의 변화추이 관찰

![]({{ site.url }}/images/faster_rcnn/Table2.png "Table2"){: .aligncenter}
Table2: Region Proposal Method을 사용했을때 보다 RPN을 사용했을때 mAP가 소폭 향상된다.

![]({{ site.url }}/images/faster_rcnn/Table3.png "Table3"){: .aligncenter}

![]({{ site.url }}/images/faster_rcnn/Table4.png "Table4"){: .aligncenter}

![]({{ site.url }}/images/faster_rcnn/Table5.png "Table5"){: .aligncenter}
Table5: RPN을 사용했을때 상당한 속도향상을 보인다.

![]({{ site.url }}/images/faster_rcnn/Table6.png "Table6"){: .aligncenter}

![]({{ site.url }}/images/faster_rcnn/Table7.png "Table7"){: .aligncenter}

![]({{ site.url }}/images/faster_rcnn/Table8.png "Table8"){: .aligncenter}
Table8: 3 scales, 3 ratios를 사용했을때 가장 성능이 잘 나온다. Anchor를 9개로 잡은 이유.

![]({{ site.url }}/images/faster_rcnn/Table9.png "Table9"){: .aligncenter}
Table9: lambda값을 조정하며 테스트. lambda가 대략 Nreg/Ncls 정도가 될때 가장 좋은 mAP를 보인다.

![]({{ site.url }}/images/faster_rcnn/Table10.png "Table10"){: .aligncenter}

![]({{ site.url }}/images/faster_rcnn/Table11.png "Table11"){: .aligncenter}

# Conclusion
실험결과에서 보이는 것처럼 약간의 정확도가 향상되었고, 실행시간이 현격히 줄어들었다. 
헌데, 논문에서 이를 'object detection system to run at near real-time frame rates' 라고 표현하는 것으로 보아, 
아직 실시간 영상처리 등에서 사용하기에는 다소 부족한 부분이 있는 것으로 보인다.

# References

* R. Girshick, J. Donahue, T.Darrel, and J. Malik, "Rich feature hierarchies for accurate object detection and semantic segmentation", [https://arxiv.org/abs/1311.2524](https://arxiv.org/abs/1311.2524)
* R. Girshick, "Fast R-CNN", [https://arxiv.org/abs/1504.08083](https://arxiv.org/abs/1504.08083)
* Shaoqing Ren, Kaiming He, Ross Girshick, Jian Sun, "Faster R-CNN", [https://arxiv.org/abs/1506.01497](https://arxiv.org/abs/1506.01497)
* py-faster-rcnn (Github Issues), "Why does it need a reshape layer in RPN's cls layer?", [https://github.com/rbgirshick/py-faster-rcnn/issues/292](https://github.com/rbgirshick/py-faster-rcnn/issues/292)
* Faster R-CNN (Caffe + Python), [https://github.com/rbgirshick/py-faster-rcnn](https://github.com/rbgirshick/py-faster-rcnn)
* Faster R-CNN (Caffe + Matlab), [https://github.com/ShaoqingRen/faster_rcnn](https://github.com/ShaoqingRen/faster_rcnn)


**Special thanks to JHS**
