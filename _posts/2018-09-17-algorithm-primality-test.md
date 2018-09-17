---
layout: post
title: "[알고리즘] 소수 판별법 (Primality Test)"
description: "효율적인 소수 판별법에 대해 알아보자."
date: 2018-09-17
tags: [algorithm]
comments: true
share: true
use_math: true
---



## 소수와 합성수

*소수 (Prime Number)*는 $$1$$과 자기 자신으로만 나누어떨어지는 자연수를 뜻한다. 가령 자연수 $$2$$는 $$1$$과 $$2$$로만 나누어떨어지므로 소수다. (참고로 $$2$$는 소수중 유일한 짝수다.)



반면 *합성수 (Composite Number)*는 $$2​$$ 이상의 자연수 중 나누어떨어지는 수(약수 또는 divisor)가 $$2​$$개 이상인 경우에 해당한다. 예를 들어 자연수 $$36​$$은 $$2​$$이상의 자연수 중 $$8​$$개의 수로 나누어떨어지므로 합성수다.

> 2, 3, 4, 6, 9, 12, 18, 36



끝으로 소수와 합성수에 전부 해당하지 않는 수가 있는데, 바로 자기 자신으로만 나누어떨어지는 수다. 자연수 $$1​$$이 그러하다.



## 약수 세기

자연수 $$n$$의 약수(divisor)를 세보도록 하자. 가장 쉬운 방법은 $$1$$에서 $$n$$까지를 순회하며 $$n$$과 나누어떨어지는지 하나하나 확인해보는 것이다. (시간복잡도: $$O(n)$$ )

```python
def n_divisors(n):
    i = 0
    result = 0
    while i <= n:
        if n % i == 0:
            result += 1
    return result
```



위의 방법보다 좀 더 효율적으로 약수를 세는 방법은 없을까? 바로 약수가 대칭성을 보인다는 특징을 활용하면 $$\sqrt{n}$$ 의 순회만으로도 약수를 세는 것이 가능하다. 다시 말하자면 자연수 $$a$$가 $$n$$의 약수일때 $$\frac{n}{a}$$ 또한 $$n$$의 약수가 되는 점을 이용하는 것이다. $$36$$을 예로 들어보겠다.



**Step1.** $$1$$과 곱해져 $$36$$이 되는 수는 $$36$$이다. 즉, $$1$$과 $$36$$은 $$36$$의 약수다.

> $$1, 36$$

**Step2.** $$2$$와 곱해져 $$36$$이 되는 수는 $$18$$이다. 즉, $$2$$와 $$18$$은 $$36$$의 약수다.

> $$1, 2, 18, 36$$

**Step3.** $$3$$과 곱해져 $$36$$이 되는 수는 $$12$$다. 즉, $$3$$과 $$12$$는 $$36$$의 약수다.

> $$1, 2, 3, 12, 18, 36$$

**Step4.** $$4$$와 곱해져 $$36$$이 되는 수는 $$9$$다. 즉, $$4$$와 $$9$$는 $$36$$의 약수다.

> $$1, 2, 3, 4, 9, 12, 18, 36$$

**Step5.** $$5​$$는 $$36​$$에 나누어떨어지지 않는다. 즉, $$5​$$는 $$36​$$의 약수가 아니다.

>  $$1, 2, 3, 4, 9, 12, 18, 36$$

**Step6.** $$6$$은 제곱하여 $$36$$이 된다. 즉, $$6$$은 $$36$$의 약수다.

> $$1, 2, 3, 4, 6, 9, 12, 18, 36$$



즉, $$36$$은 $$9$$개의 약수를 갖는다. 단 $$6$$번만의 순회로 $$36$$의 모든 약수를 확인했다.

이 방법을 파이썬 코드로 구현해보면 아래와 같다. (시간복잡도: $$O(\sqrt{n})$$)

```python
def n_divisors(n):
    i = 1
    result = 0
    while i * i < n:
        if n % i == 0:
            result += 2  # Count symmetric divisors
        i += 1
    if i * i == n:
        result += 1
    return result
```



## 소수 판별법

[2, n]의 범위에 약수가 존재하는지 확인함으로써 *소수 판별법 (primality test)*을 구현할 수 있다. (시간복잡도: $$O(\sqrt{n})$$ ) 

```python
def primality(n):
    i = 2
    while i * i <= n:
        if n % i == 0:
            return False
        i += 1
    return True
```

1은 소수도 합성수도 아니므로 이 알고리즘은 $$n \ge 2$$ 를 만족하는 경우에만 동작한다. 



## 연습문제: MinPerimeterRectangle

**출처:** Codility *Lesson 10* - [MinPerimeterRectangle](https://app.codility.com/programmers/lessons/10-prime_and_composite_numbers/min_perimeter_rectangle/)



#### Task Description: 

An integer N is given, representing the area of some rectangle.

The *area* of a rectangle whose sides are of length A and B is A * B, and the *perimeter* is 2 * (A + B).

The goal is to find the minimal perimeter of any rectangle whose area equals N. The sides of this rectangle should be only integers.

For example, given integer N = 30, rectangles of area 30 are:

> - (1, 30), with a perimeter of 62,
> - (2, 15), with a perimeter of 34,
> - (3, 10), with a perimeter of 26,
> - (5, 6), with a perimeter of 22.

Write a function:

> ```
> def solution(N)
> ```

that, given an integer N, returns the minimal perimeter of any rectangle whose area is exactly equal to N.

For example, given an integer N = 30, the function should return 22, as explained above.

Write an **efficient** algorithm for the following assumptions:

> - N is an integer within the range [1..1,000,000,000].



#### Solution: 

* Detected time complexity: **O(sqrt(N))**

```python
def solution(N):
    min_perimeter = 2 * (1 + N)
    i = 2
    while i ** 2 <= N:
        if N % i == 0:
            A, B = i, N // i
            min_perimeter = min(2*(A+B), min_perimeter)
        i += 1
    return min_perimeter
```



## 참고자료

* Khan Academy (2011). *Recognizing prime and composite numbers*. [Video]. Available at: https://www.khanacademy.org/math/pre-algebra/pre-algebra-factors-multiples/pre-algebra-prime-numbers/v/recognizing-prime-numbers [Accessed 17 Sep. 2018].

* Codility (Unknown). *Prime and composite numbers*. [Online]. Available at: https://app.codility.com/programmers/lessons/10-prime_and_composite_numbers/ [Accessed 17 Sep. 2018].