---
layout: post
title: "[Algorithms] MaxDoubleSliceSum"
description: "Find the maximal sum of any double slice."
date: 2018-09-14
tags: [algorithms]
comments: true
share: true
use_math: false
---

One of Maximum Slice Problems in Codility's Lessons. [[Link](https://app.codility.com/programmers/lessons/9-maximum_slice_problem/max_double_slice_sum/)]



## Task Description

A non-empty array A consisting of N integers is given.

A triplet (X, Y, Z), such that 0 ≤ X < Y < Z < N, is called a *double slice*.

The *sum* of double slice (X, Y, Z) is the total of A[X + 1] + A[X + 2] + ... + A[Y − 1] + A[Y + 1] + A[Y + 2] + ... + A[Z − 1].

For example, array A such that:

​    A[0] = 3     A[1] = 2     A[2] = 6     A[3] = -1     A[4] = 4     A[5] = 5     A[6] = -1     A[7] = 2



contains the following example double slices:

> - double slice (0, 3, 6), sum is 2 + 6 + 4 + 5 = 17,
> - double slice (0, 3, 7), sum is 2 + 6 + 4 + 5 − 1 = 16,
> - double slice (3, 4, 5), sum is 0.

The goal is to find the maximal sum of any double slice.

Write a function:

> ```
> def solution(A)
> ```

that, given a non-empty array A consisting of N integers, returns the maximal sum of any double slice.

For example, given:

​    A[0] = 3     A[1] = 2     A[2] = 6     A[3] = -1     A[4] = 4     A[5] = 5     A[6] = -1     A[7] = 2



the function should return 17, because no double slice of array A has a sum of greater than 17.

Write an **efficient** algorithm for the following assumptions:

> - N is an integer within the range [3..100,000];
> - each element of array A is an integer within the range [−10,000..10,000].



## My Answer

* Detected time complexity: **O(N)**

You can see the description in the comment.

```python
def solution(A):
    l_max_slice_sum = [0] * len(A)
    r_max_slice_sum = [0] * len(A)

    for i in range(1, len(A)-2): # A[X + 1] + A[X + 2] + ... + A[Y − 1]
        # Let's assume that Y is equal to i+1.
        # If l_max_slice_sum[i-1] + A[i] is negative, we assign X to i.
        # It means that the slice sum is 0 because X and Y are consecutive indices.
        l_max_slice_sum[i] = max(l_max_slice_sum[i-1] + A[i], 0)

    for i in range(len(A)-2, 1, -1): # A[Y + 1] + A[Y + 2] + ... + A[Z − 1]
        # We suppose that Y is equal to i-1.
        # As aforementioned, Z will be assigned to i if r_max_slice_sum[i+1] + A[i]
        # is negative, and it returns 0 because Y and Z becomes consecutive indices.
        r_max_slice_sum[i] = max(r_max_slice_sum[i+1] + A[i], 0)

    max_slice_sum = l_max_slice_sum[0] + r_max_slice_sum[2]
    for i in range(1, len(A)-1):
        # Let's say that i is the index of Y.
        # l_max_slice_sum[i-1] is the max sum of the left slice, and
        # r_max_slice_sum[i+1] is the max sum of the right slice.
        max_slice_sum = max(max_slice_sum, l_max_slice_sum[i-1]+r_max_slice_sum[i+1])
        
    return max_slice_sum
```

