---
layout: post
title: "[정리] Algorithms for Inverse Reinforcement Learning"
description: "Algorithms for Inverse Reinforcement Learning (NG et al., 2000)"
date: 2019-05-05
tags: [inverse reinforcement learning]
comments: true
share: true
use_math: true
---

![title]({{ site.url }}/images/algo_for_irl/cover.png){: .aligncenter}

[Paper](http://ai.stanford.edu/~ang/papers/icml00-irl.pdf)

본 논문에서는 Inverse Reinforcement Learning (이하 IRL)을 정의하고, 이를 Linear Programming으로 formulation한다. IRL은 관찰된 optimal behaviour로부터 적합한 reward function을 도출해내는 것이다. 여기서 reward function이란 어떤 task에 대한 목적을 담고 있다고 볼 수 있다. 잘 정의된 reward function은 우리가 원하는대로 agent를 움직일 수 있도록 할 것이다.

Finite state space에서의 IRL 문제는 다음과 같이 정의한다.


$$
\begin{align*}
\max \sum_{i=1}^N \min_{a \in \{a_2, ..., a_k\}} \{(P_{a_1}(i) - P_{a}(i))(I - \gamma P_{a_1})^{-1}R\} - \lambda \| R\|_1\\

\text{s.t. } (P_{a_1}(i) - P_{a}(i))(I - \gamma P_{a_1})^{-1}R \succeq 0, \forall a \in A \backslash a_1\\
|R_i| \leq R_{max}, i=1, ..., N,\\

\text{where } P_a(i) \text{ denotes the } i \text{th row of } P_a.\\
\end{align*}
$$


위 문제의 제약함수 중 $$(P_{a_1}(i) - P_{a}(i))(I - \gamma P_{a_1})^{-1}R \succeq 0$$는 state value의 평균이 최대가 되는 것을 보장하는 조건이다 (논문 Theorem3의 증명 참고). 단, 이 제약조건 만으로는 다음과 같은 두 가지 문제가 발생할 수 있다.

  * $$R = 0$$일때 항상 solution이다.
  * $$R$$에 대해 너무나 많은 후보가 발생할 수 있다.

설정한 목적함수를 잘 살펴보면 솔루션 중에서도 0이 아니면서도 가급적 작고 sparse한 R을 찾고자 한다는 것을 알 수 있다 (simplest R).


더불어 Large state spaces에서는 linear function approximation을 통해 새로운 문제를 정의한다. Finite state space에서 $$(P_{a_1}(i) - P_{a}(i))(I - \gamma P_{a_1})^{-1}R \succeq 0$$와 비슷한 역할을 할 수 있는 조건을 다음과 같이 정의한다.

$$E_{s' \sim P_{sa_1}} [V^\pi (s')] \ge E_{s' \sim P_{sa}} [V^\pi (s')] \text{ ,where }\pi(s) \equiv a_1$$

그리고 위 조건에서 예상되는 두 가지 문제와 함께 다음과 같은 방안을 제시한다.

  * infinite space에서의 계산문제: finite subset으로 sampling을 한다.
  * linear approximation으로 optimal policy에 대한 reward function을 표현하지 못할 가능성: Relaxation을 통해 위 도메인 집합의 크기를 키운다.

최종적으로 정의한 문제는 다음과 같다.

$$
\begin{align*}
\max \sum_{s \in S_0} \min_{a \in \{a_2, ..., a_k\}} \{p(E_{s' \sim P_{sa_1}} [V^\pi (s')] \ge E_{s' \sim P_{sa}}[V^\pi (s')] )\}\\
s.t. |\alpha_i | \le 1, i = 1, ..., d.
\end{align*}
$$


실험에서 위의 최적화 문제는 optimal policy에 대한 true reward function을 매우 유사하게 추론하는 결과를 보인다.

-----------------------------