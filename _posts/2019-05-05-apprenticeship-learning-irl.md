---
layout: post
title: "[정리] Apprenticeship Learning via Inverse Reinforcement Learning"
description: "Apprenticeship Learning via Inverse Reinforcement Learning (Abbeel et al., 2004)"
date: 2019-05-05
tags: [inverse reinforcement learning]
comments: true
share: true
use_math: true
---

![title]({{ site.url }}/images/app/title.png){: .aligncenter}

[Paper](http://people.eecs.berkeley.edu/~russell/classes/cs294/s11/readings/Abbeel+Ng:2004.pdf)

때로 reward function을 수작업으로 정의하기가 굉장히 어려운 경우가 있다. 자율주행의 경우 여러 평가항목에 대한 weighted sum으로 reward function을 정의할 수 있는데, 여기서 weight를 결정하는 것을 하나의 예로 볼 수 있다. 이 연구에서는 reward function이 known feature에 대한 학습가능한 linear combination이라고 가정하고, expert trajectory로부터 reward function을 추정하는 방법에 대해 알아보도록 한다.

주어진 MDP\R (reward가 없는 MDP 문제)에서 feature mapping을 $$\phi$$, 전문가의 feature expectations를 $$\mu_E$$라고 할때, 목표는 전문가와 유사한 performance를 내는 unknown reward function $$R^* = w^{*T}\phi$$를 찾는 것이다. 전문가와 유사한 performance는 다음의 조건으로 정의하도록 한다: $$\| \mu(\tilde{\pi}) - \mu_E \| \le \epsilon$$ for $$\|w\|_1 \le 1 (w \in \mathbb{R}^k)$$.

$$
\begin{align*}
E [ \sum_{t=0}^{\infty} \gamma^t R(s_t) | \pi_E ] - E [ \sum_{t=0}^{\infty} \gamma^t R(s_t) | \tilde{\pi} ] &= | w^T \mu(\tilde{\pi}) - w^T \mu_E | \\
&\le \|w\|_2 \| \mu(\tilde{\pi}) - \mu_E \|_2 \\
&\le 1 \cdot \epsilon = \epsilon
\end{align*}
$$


논문에서 제시하는 apprenticeship learning algorithm은 다음의 절차를 통해 $$\tilde{\pi}$$를 찾는 것이다.

  - 임의의 initial policy $$\pi^{(0)}$$를 고르고, $$\mu^{(0)} = \mu(\pi^{(0)})$$를 계산한다.
  - $$t^{(i)} = \max_{w:\|w\|_2 \le 1} \min_{j \in \{0..(i-1)\}} w^T(\mu_E - \mu^{(j)})$$를 계산한다.
  - 만약 $$t^{(i)} \le \epsilon$$을 만족하면 알고리즘을 종료한다.
  - Reward function을 $$R = (w^{(i)})^T\phi$$로 설정하고 이때의 optimal policy $$\pi^{(i)}$$를 계산한다.
  - $$\mu^{(i)} = \mu(\pi^{(i)})$$를 계산한다.
  - $$i = i+1$$로 설정하고 step 2로 돌아간다.

위 알고리즘의 step2의 max, min문제는 각각 다음과 같이 나누어 볼 수 있다.

### max 문제

$$
\begin{align*}
\max_{t, w} \: t\\
\text{s.t. } w^T \mu_E \ge w^T \mu^{(j)} + t, j = 1, ..., i-1,\\
\|w\|_2 \le 1.
\end{align*}
$$





전문가의 policy가 좀 더 높은 reward를 가질 수 있도록 margin $$t$$를 최대화하는 문제로 볼 수 있다.

### min 문제

$$
\begin{align*}
\min \| \mu_E - \mu \|_2\\
\text{s.t. } \mu = \sum_i \lambda_i \mu^{(i)},\\
\sum_i \lambda_i = 1,\\
\lambda \ge 0.\\
\end{align*}
$$



반면, min문제는 $$\mu^{(0)}, ..., \mu^{(n)}$$의 convex closure에서 $$\mu^E$$와 가장 유사한 지점을 찾는 Quadratic Programming (QP)으로 볼 수 있다.

논문에서는 위 알고리즘을 **max-margin**이라 명하고, 또한 QP보다 좀 더 복잡도가 낮은 **projection method**를 제안한다. 자세한 내용은 논문의 3.1을 참고하자.

4절에서는 제시한 알고리즘의 이론적 분석을 통해 $$O(\frac{k}{(1-\gamma)^2 \epsilon^2}\log \frac{k}{(1-\gamma)\epsilon})$$만에 알고리즘이 종료될 수 있으며, 최종적인 성능은 전문가와 비교해 $$O(\| \epsilon \|_{\infty})$$보다 더 떨어지지 않음을 보인다.

마지막으로 5절의 실험에서는 본 방법론의 실제 수렴여부 및 학습 속도에 대해 살펴본다. IRL 방식은 전문가의 trajectory를 무작정 따라하는 방식(supervised learning)보다 월등히 좋은 성능을 보인다.

-----------------------------