+++
title = "Codeforces #713(Div.3) <br> E: Permutation by Sum"
author = ["Yudai Fukushima"]
date = 2021-05-09
lastmod = 2021-05-09T11:37:13+09:00
categories = ["Codeforces"]
draft = true
thumbnail = "images/cf.png"
description = "Codeforces #713 E"
+++

## Problem Overview {#problem-overview}

-   Consider the permutation 1 to \\(n\\) called P.
-   The parameters \\(l, r, s\\) that satisfies \\(1 \leq l \leq r \leq n\\) and \\(1 \leq s \leq \frac{n(n + 1)}{2}\\) are give.
-   Find the permutation which satisfies \\(P\_{l} + P\_{l + 1} + ... + P\_{r} = s\\).
-   Print any permutation of length \\(n\\) that fits the condition above if such a permutation exists; otherwise, -1.


## Problem Explanation {#problem-explanation}

First, the minimum and the maximum value we can generate with the length \\(r - l + 1\\).  
Hereafter, we define \\(k = r - l + 1\\).  

**Minimum Value**  
As an arithmetic sequence with first term 1, term number \\(m\\), and tolerance -1, we can derive the minimum value.  
\\(min(m) = \frac{m(m + 1)}{2}\\)  

**Maximum Value**  
As an arithmetic sequence with first term \\(x\\), term number \\(m\\), and tolerance -1, we can derive the maximum value.  

\\(max(x, m) = \frac{m \* (2 \* x + (m - 1) \* -1)}{2}\\)    
\\(max(x, m) = \frac{m(2x - m + 1)}{2}\\)  

Any number \\(s\\) that satisfies \\(min(k) \leq s \leq max(n, k)\\) meet the condition.  

**Coding**  
First, we prepare the vector \\(res\\) with size \\(n\\) to push the results.  
Consider in descending order.  
Start the for loop from \\(n\\),  
if \\(i\\) meets the condition \\(max(i) - s \geq 0\\) and \\(s - i \geq min(k - 1)\\),  
put \\(i\\) to the \\(res[l + k - i]\\) and replace \\(k = k - 1, s = s - i\\).  
Iterate this until \\(k\\) becomes 0, and then if \\(s = 0\\) is achieved, we find the permuation; otherwise, prints -1.  
The remaining part of the implementation is to insert the unused numbers into the empty parts of the vector.  

[Source Code](https://codeforces.com/contest/1512/submission/115426822)
