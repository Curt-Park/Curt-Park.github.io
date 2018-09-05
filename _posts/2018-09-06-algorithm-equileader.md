---
layout: post
title: "[알고리즘] EquiLeader"
description: "Find the index S such that the leaders of the sequences A[0], A[1], ..., A[S] and A[S + 1], A[S + 2], ..., A[N - 1] are the same."
date: 2018-09-06
tags: [algorithm]
comments: true
share: true
use_math: false
---

Codility의 연습문제: [Lesson 8 Leader - EquiLeader](https://app.codility.com/programmers/lessons/8-leader/equi_leader/)



## 문제

A non-empty array A consisting of N integers is given.

The *leader* of this array is the value that occurs in more than half of the elements of A.

An *equi leader* is an index S such that 0 ≤ S < N − 1 and two sequences A[0], A[1], ..., A[S] and A[S + 1], A[S + 2], ..., A[N − 1] have leaders of the same value.

For example, given array A such that:

​    A[0] = 4     A[1] = 3     A[2] = 4     A[3] = 4     A[4] = 4     A[5] = 2

we can find two equi leaders:

> - 0, because sequences: (4) and (3, 4, 4, 4, 2) have the same leader, whose value is 4.
> - 2, because sequences: (4, 3, 4) and (4, 4, 2) have the same leader, whose value is 4.

The goal is to count the number of equi leaders.

Write a function:

> `def solution(A)`

that, given a non-empty array A consisting of N integers, returns the number of equi leaders.

For example, given:

​    A[0] = 4     A[1] = 3     A[2] = 4     A[3] = 4     A[4] = 4     A[5] = 2

the function should return 2, as explained above.

Write an **efficient** algorithm for the following assumptions:

> - N is an integer within the range [1..100,000];
> - each element of array A is an integer within the range [−1,000,000,000..1,000,000,000].



## 답변

* **Detected Time Complexity:** O(N)

```python
from collections import defaultdict

def solution(A):
    # write your code in Python 3.6
    marker_l = defaultdict(lambda : 0)
    marker_r = defaultdict(lambda : 0)
    
    for i in range(len(A)): 
        marker_r[A[i]] += 1
    
    n_equi_leader = 0
    leader = A[0]
    for i in range(len(A)):
        marker_r[A[i]] -= 1
        marker_l[A[i]] += 1
        
        if i == 0 or marker_l[leader] < marker_l[A[i]]:
            leader = A[i]
            
        if (i+1) // 2 < marker_l[leader] and (len(A) - (i+1)) // 2 < marker_r[leader]:
            n_equi_leader += 1
            
    return n_equi_leader
```

defaultdict는 Python dictionary object (PyDictObject)에 default_factory가 붙어있는 형태를 하고있다 (참고: [CPython 소스코드](https://hg.python.org/cpython/file/tip/Modules/_collectionsmodule.c#l1974)). Factory의 동작에 따라 발생하는 약간의 성능차이를 제외하면 (참고: [Stackoverflow](https://stackoverflow.com/a/19643045)) dict와 동일한 시간복잡도를 가진다 (참고: [UCI ICS-46 강의자료](https://www.ics.uci.edu/~pattis/ICS-33/lectures/complexitypython.txt)). defaultdict는 내부적으로 hash table을 사용하며 insertion 연산에 평균적으로 O(1)의 시간복잡도를 보인다 (참고: [파이썬위키](https://wiki.python.org/moin/TimeComplexity)).

* **더 읽을거리**: [Everything about Python dict - Stackoverflow](https://stackoverflow.com/a/9022835)