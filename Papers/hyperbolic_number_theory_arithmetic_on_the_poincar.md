# Computational Evidence

## Small-case calculations

For the recurrence $u_0=2$, $u_1=3$, $u_{n+2}=3u_{n+1}-u_n$, the first terms are

| $n$ | 0 | 1 | 2 | 3 | 4 | 5 |
|---:|---:|---:|---:|---:|---:|---:|
| $u_n$ | 2 | 3 | 7 | 18 | 47 | 123 |

The doubling law predicts $u_2=u_1^2-2=7$, $u_4=u_2^2-2=47$, and $u_{10}=u_5^2-2=15127$. The tripling law predicts $u_3=u_1^3-3u_1=18$ and $u_{12}=u_4^3-3u_4=103682$. These identities are represented by concrete examples in `TraceDoubling.lean` and follow there from general theorems.

The discriminant calculation at $n=2$ gives
\[
 u_4^2-4=47^2-4=2205=(7^2-4)7^2,
\]
matching the general square-factor identity.

## OEIS search

No OEIS result was supplied in the research prompt, and no external sequence identification was used. The recurrence data are therefore recorded without assigning an OEIS identifier.

## Counterexample hunt and boundary cases

The proposed identities were checked symbolically for arbitrary integral trace parameter, so no counterexample occurs within that scope. The parabolic boundary $t=2$ was tested explicitly: the sequence is constantly $2$, its trace discriminant is zero, and the doubled discriminant identity remains valid. This boundary example is included in `TraceDoubling.lean`.

The broader claims about unique factorization of tessellation vertices and a critical-line zero law were not tested numerically because the proposed operations, norm, and zeta function do not yet determine canonical mathematical objects. Finite zero computations would in any case provide evidence rather than a proof of a universal zero-location statement.
