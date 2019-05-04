---
layout: post
title: "[Algorithms] MaxSliceSum"
description: "Find a maximum sum of a compact subsequence of array elements."
date: 2018-09-13
tags: [algorithms]
comments: true
share: true
use_math: false
---

One of Maximum Slice Problems in Codility's Lessons. [[Link](https://app.codility.com/programmers/lessons/9-maximum_slice_problem/max_slice_sum/)]



This is a problem in beginner's level, and the final answer is really simple. However, I post it as a reminder since I took a long to solve it. 



## Task Description

A non-empty array A consisting of N integers is given. A pair of integers (P, Q), such that 0 ≤ P ≤ Q < N, is called a *slice* of array A. The *sum* of a slice (P, Q) is the total of A[P] + A[P+1] + ... + A[Q].

Write a function:

> ```
> def solution(A)
> ```

that, given an array A consisting of N integers, returns the maximum sum of any slice of A.

For example, given array A such that:

A[0] = 3  A[1] = 2  A[2] = -6 A[3] = 4  A[4] = 0



the function should return 5 because:

> - (3, 4) is a slice of A that has sum 4,
> - (2, 2) is a slice of A that has sum −6,
> - (0, 1) is a slice of A that has sum 5,
> - no other slice of A has sum greater than (0, 1).

Write an **efficient** algorithm for the following assumptions:

> - N is an integer within the range [1..1,000,000];
> - each element of array A is an integer within the range [−1,000,000..1,000,000];
> - the result will be an integer within the range [−2,147,483,648..2,147,483,647].



## My Answer

* **Detected Time Complexity:** O(N)

It uses two variables: 'max' to represent maximum sum and 'acc' for storing cumulative sum. If acc is  negative at the current step, it restarts cumulative sum by assigning 0; that is because the next sum would be negatively affected.

```python
def solution(A):
    max = A[0]
    acc = 0
    
    for e in A:
        acc += e
        if acc > max:
            max = acc
            
        if acc < 0:
            acc = 0
                
    return max
```



**Another Answer**

We can get the same solution by using 2 max functions. The first max gets cumulative sum for the current slice, and the second max keeps or updates the max slice sum.

```python
def solution(A):
    max_sum = sub_sum = A[0]
    for i in range(1, len(A)):
        sub_sum = max(sub_sum + A[i], A[i])
        max_sum = max(max_sum, sub_sum)
    
    return max_sum
```

