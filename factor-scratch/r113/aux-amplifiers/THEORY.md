# Auxiliary-information amplifiers on top of known-high-bits-of-p — theory (derived here, not cited)

Setup: N = p q balanced, n = log2(N), p ~ 2^(n/2). Leak: a = top bits of p, x0 = p - a,
0 <= x0 < X. f(x) = x + a is MONIC of degree d = 1. p is an unknown factor.

## (0) Univariate Coppersmith / Howgrave-Graham bound
For monic f of degree d, small root mod an unknown factor b >= B^beta of modulus B:
    X < B^(beta^2 / d - eps)
d = 1, B = N, beta = 1/2 (balanced):
    log2 X < n/4 .                                         [PLAIN CEILING]
Equality is not attained (eps > 0), so the achieved value is strictly below.

## (a) The multiplier u:  work mod M = u*N
p | M as well. But p's size RELATIVE TO THE MODULUS SHRINKS:
    beta(u) = log2(p)/log2(uN) = (n/2)/(n+w),   w = log2(u).
Substituting into the same bound:
    log2 X < beta(u)^2 * log2(M) = (n/2)^2/(n+w) = (n/4) * n/(n+w)
                      ^^^^^^^^^^^^^              ^^^^^^^^^^^^^^^^
    X_ceiling(u) = (n/4) * n/(n+w)  <  n/4  for every u > 1.    [REFUTED-BY-CONSTRUCTION]
The loss is n/4 - X_ceiling(u) ~ (n/4)*(w/n) ~ w/4 bits.
For w = 1 (u=2) and n = 1024 the loss is 0.25 bits — SUB-BIT.

=> Predicted measured effect of u: strictly SMALLER ceiling, by only ~w/4 bits,
   which at practical moduli is far below the grid resolution of a bit-count.
   Any "gain" seen at integer bit resolution would be lattice luck, not amplification.

## (b) Knowing high bits of BOTH p and q
q = N/p. dq/dp = -N/p^2 = -q/p.  So an uncertainty X in p induces an uncertainty
X*(q/p) in q. Hence knowing p to precision X ALREADY fixes q to precision X*q/p.

=> q's leak is INDEPENDENT of p's leak (carries no new information about p) iff
       Y <= X * (q/p),   where Y = known precision of q.
   For balanced p~q this is Y <= X: a symmetric two-factor leak is REDUNDANT.
   For unbalanced p<q it is Y <= X*q/p: q's leak is redundant, and conversely a leak
   on the LARGER factor is strictly WEAKER than the same-size leak on the smaller.
The bivariate form (a+x)(b+y) = N over Z is exactly the bilinear constraint
   x*y + b*x + a*y = N - a*b,
whose integer solutions are exactly the divisor pairs of N in the two intervals.
So the bivariate attack's region is capped by the p-interval: no extension.
