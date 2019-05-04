---
layout: post
title: "[Algorithms] EquiLeader"
description: "Find the index S such that the leaders of the sequences A[0], A[1], ..., A[S] and A[S + 1], A[S + 2], ..., A[N - 1] are the same."
date: 2018-09-06
tags: [algorithms]
comments: true
share: true
use_math: false
---

Codility's Lessons: [Lesson 8 Leader - EquiLeader](https://app.codility.com/programmers/lessons/8-leader/equi_leader/)



Thanks to this task, I have learned the average time complexity of python's dict family. Unlike my initial expectation, it shows just O(1) for insertion operation. I thought the inner structure of it would be balanced tree such as the usual implementation of std::map in C++. [[Reference](https://en.cppreference.com/w/cpp/container/map)]



## Task Description

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



## My Answer

* **Detected Time Complexity:** O(N)

As seen in [CPython implementation](https://hg.python.org/cpython/file/tip/Modules/_collectionsmodule.c#l1974), defaultdict is a type consisting of Python dictionary object (PyDictObject) and default_factory. Aside from the running cost of default_factory, it has the same time complexity as dict ([Stackoverflow](https://stackoverflow.com/a/19643045), [UCI ICS-46](https://www.ics.uci.edu/~pattis/ICS-33/lectures/complexitypython.txt)). defaultdict explicits Hash Table and shows just O(1) for insertion operation in average ([Python Wiki](https://wiki.python.org/moin/TimeComplexity)).

**More read**: [Everything about Python dict - Stackoverflow](https://stackoverflow.com/a/9022835)

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
