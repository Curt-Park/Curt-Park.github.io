---
layout: post
title: "[분석] Stacked Hourglass Networks for Human Pose Estimation"
description: ""
date: 2018-07-03
tags: [human pose estimation]
comments: true
share: true
use_math: true
---

![title]({{ site.url }}/images/stacked_hourglass_networks/title.png "title"){: .aligncenter}



## Introduction

사진 속에 담긴 사람들에 대해 더욱 이해를 높이기 위해서는 그들이 취하고 있는 포즈에 대해 먼저 이해하는 것이 중요하다. 이러한 연구주제를 human pose estimation이라고 하며, 이는 computer vision에서 오랫동안 다루어지고 있는 분야이기도 하다. 근래의 pose estimation system들은 대부분 수작업으로 생성한 feature들이나 graphical model을 사용하는 것에서 ConvNets을 주요 구조에 반영하는 것으로 옮겨갔다. 이 연구에서는 ConvNets을 이용하는 것의 연장선으로, 이미지의 모든 scale에 대한 정보를 downsampling의 과정에서 추출하고 이를 upsampling 과정에 반영하여 pixel-wise output을 생성하는 것을 목표로 한다. 또한 이 아이디어(single hourglass)를 확장하여 여러 hourglass module을 연속하여 잇는 방식인 Stacked Hourglass Networks 구조를 소개한다. 이 구조는 여러 scale들에 대해 반복적인 bottom-up, top-down inference*를 가능하게 하며, 표준 pose estimation benchmarks(FLIC and MPII Human Pose)에서 확연한 성능 향상을 보여준다.<br/>

(* Inference를 하기까지 차원축소의 단계와 차원증가의 단계를 거치는 형태를 명칭하는 것으로 보인다.)

![title]({{ site.url }}/images/stacked_hourglass_networks/fig1.png "fig1"){: .aligncenter}



## Network Architecture

#### Hourglass Design

![title]({{ site.url }}/images/stacked_hourglass_networks/fig3.png "fig3"){: .aligncenter}

얼굴이나 손과 같은 feature들을 식별하는 것에는 local evidence가 중요한 반면, 최종적인 포즈의 추정하기 위해서는 full body에 대한 이해가 필요하다. 그리고 이를 위해서는 여러 scale에 걸쳐 필요한 정보를 포착해낼 수 있어야 한다. Hourglass는 이러한 모든 feature들을 잡아내어 네트워크의 출력인 픽셀 단위의 예측에 반영하도록 한다. 기존의 몇몇 방식들이 여러 크기에 대한 feature를 뽑아내기 위해 분리된 다수의 파이프라인을 사용한 반면, 이 연구에서는 skip layer를 이용하여 단 하나의 파이프라인 만으로 spatial information을 유지하는 방식을 채택하였다.<br/>

Hourglass Network는 다음과 같은 구조를 보인다.

- Feature의 추출과 저차원으로의 downsampling을 위해 Convlutional layer와 maxpooling layer를 사용한다.
- 매 max pooling 단계에서의 입력을 또한 별도의 branch로 내보내고 이에 convolution 연산을 적용한다. 이를 통해 scale 마다의 feature가 추출된다.
- 가장 낮은 resolution에 도달한 후, upsampling 과정에서 scale 별로 추출한 feature들을 조합한다. Upsampling으로는 Nearest Neighbor Upsampling[2] 방식을, feature와의 조합에는 elementwise addition 연산을 이용한다.
- 네트워크는 대칭적인 구조를 띈다.
- Output resolution에 다다르면 두번의 연속된 1x1 convolution 연산을 적용하여 최종적인 예측값을 출력한다.
- 네트워크의 출력은 각 관절에 대한 추정(확률)값이 담긴 heatmap들이다.  (아래 Figure2)

위의 Figure 3는 마지막의 1x1 convolution 단계를 제외한 네트워크 전체 구조다. 

![title]({{ site.url }}/images/stacked_hourglass_networks/fig2.png "fig2"){: .aligncenter}



#### Layer Implementation

![title]({{ site.url }}/images/stacked_hourglass_networks/fig4-left.png "fig4-left"){: .aligncenter}

Figure3의 각 box는 위 그림과 같은 residual module이다. 3x3보다 큰 filter는 사용되지 않고 메모리 사용량의 줄이기 위해 bottelneck 구조를 이용한다.<br/>

눈여겨볼 점은 해상도가 256x256일때 굉장히 높은 GPU 메모리 사용량을 요구하기 때문에 아래와 같은 이미지 전처리 과정을 거친다는 것이다[[3](https://github.com/umich-vl/pose-hg-train/blob/master/src/models/hg.lua#L37)]. 64x64 크기의 입력으로도 성능에는 지장이 없다고 한다.

```lua
-- Input size: (256, 256, 3)

-- Initial processing of the image
local cnv1_ = nnlib.SpatialConvolution(3,64,7,7,2,2,3,3)(inp)           -- 128
local cnv1 = nnlib.ReLU(true)(nn.SpatialBatchNormalization(64)(cnv1_))
local r1 = Residual(64,128)(cnv1)
local pool = nnlib.SpatialMaxPooling(2,2,2,2)(r1)                       -- 64
local r4 = Residual(128,128)(pool)
local r5 = Residual(128,opt.nFeats)(r4)
```

1. 7x7 convolutional layer with stride2 (w&h size: 256 -> 128, output channel: 64)
2. a residual module (w&h size: 128, output channel: 128)
3. max pooling layer (w&h size: 128 -> 64, output channel: 128)
4. Two subsequent residual modules (output channel: 256)

참고로 Hourglass Network 내부의 모든 residual model은 output channel의 크기가 256이다.



#### Stacked Hourglass with Intermediate Supervision

![title]({{ site.url }}/images/stacked_hourglass_networks/fig4-right.png "fig4-right"){: .aligncenter}

Stacked Hourgalss Networks는 다수의 Hourglass Network를 쌓아놓은 구조다. 이 구조는 반복적인 bottom-up, top-down inference를 가능하게 하며, 이를 통해 initial estimates와 이미지 전반에 대한 feature를 다시금 추정(reevaluation)할 수 있게 한다(위 그림 참조). 여기서 중요한 점은 중간중간에서 얻어지는 예측값(the prediction of intermideate heatmaps)들에 대해서도 ground truth와의 loss를 적용할 수 있다는 것이다 (Intermediate Supervision). 반복적인 예측값의 조정으로 좀 더 세밀한 결과를 도출할 수 있으며, 중간중간 적용되는 loss로 인해 좀 더 깊고 안정적인 학습이 가능하리라 예상할 수 있다. <br/>

그렇다면 그 방법에 대해 알아보도록 하자 (위 그림 참고). Intermediate predictions에 1x1 convolutional filter를 적용하여 그 차원수를 증가시키고, 이를 이번 hourglass의 intermediate features와 이전 hourglass stage에서의 features output과 합산한다. 그리고 이 합산 결과는 고스란히 연이어 등장하는 hourglass module의 입력이 된다. (최종적인 network design에서는 8개의 hourglass module이 사용되었다.)<br/>

**! 주의할 점**

1. Hourglass module간에 가중치를 공유하지 않는다.
2. Loss를 계산할때, 모든 hourglass들의 prediction에 대해 동일한 ground truth를 사용한다.



## Experiments

MPII와 FLIC dataset에서 standard Percentage of Correct Keypoints (PCK)를 이용한 성능평가. 모든 방면에서 월등히 우수한 성능을 보인다.

![title]({{ site.url }}/images/stacked_hourglass_networks/experiement1.png "experiement1"){: .aligncenter}



5가지 서로 다른 네트워크 구조들의 성능을 비교한 결과다.

![title]({{ site.url }}/images/stacked_hourglass_networks/fig8.png "fig8"){: .aligncenter}



네트워크가 깊어질수록 intermediate prediction accuracy가 서서히 높아지는 것을 볼 수 있다.

![title]({{ site.url }}/images/stacked_hourglass_networks/fig9.png "fig9"){: .aligncenter}



다수의 사람이 한 사진에 담겨 있을때, 네트워크는 사진의 중앙에 있는 사람에 대해 동작하는 경향성을 보인다.

![title]({{ site.url }}/images/stacked_hourglass_networks/fig10.png "fig10"){: .aligncenter}



## Conclusion

(본문을 그대로 삽입)<br/>

We demonstrate the effectiveness of a stacked hourglass network for producing human pose estimates. The network handles a diverse and challenging set of poses with a simple mechanism for reevaluation and assessment of initial predic- tions. Intermediate supervision is critical for training the network, working best in the context of stacked hourglass modules. There still exist difficult cases not handled perfectly by the network, but overall our system shows robust perfor- mance to a variety of challenges including heavy occlusion and multiple people in close proximity. 



## References

1. Newell, A., Yang, K., Deng, J. (2016). *Stacked Hourglass Networks for Human Pose Estimation*.  [Computer Vision – ECCV 2016](https://link.springer.com/book/10.1007/978-3-319-46484-8), pp. 483-499.
2. [Computerphile](https://www.youtube.com/channel/UC9-y-6csu5WGm29I7JiwpnA) (2016). *Resizing Images*. [Video]. Available at: https://youtu.be/AqscP7rc8_M [Accessed 3 Jul. 2018].
3. Michigan Vision & Learning Lab. (2015). *Stacked Hourglass Networks for Human Pose Estimation (Training Code)*. [Code]. Available at: https://github.com/umich-vl/pose-hg-train [Accessed 3 Jul. 2018]