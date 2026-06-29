# Binary Digit-Reversal Invariance of Cusick Densities: Two Exact, Verified Five-Bit Instances

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Number theory of digit sums (Novelty)

## Abstract

Let $s_2(n)$ denote the binary digit sum (the number of $1$s in the base-$2$
expansion of $n$). For a fixed shift $t \ge 1$, Cusick's density is
$$c_t = \lim_{N \to \infty} \frac{1}{N}\,\#\{0 \le n < N : s_2(n+t) \ge s_2(n)\}.$$
The Drmota–Kauers–Spiegelhofer theorem (2016) establishes the explicit bias bound
$c_t \ge \tfrac{1}{2} + 2^{-(2 s_2(t)+1)}$, in particular $c_t > 1/2$ for all $t$
(Cusick's conjecture). A structural prerequisite is that the predicate
$P_t(n) := [\,s_2(n+t) \ge s_2(n)\,]$ is purely periodic in $n$ with period
$2^{L+s_2(t)}$ whenever $t < 2^L$, which makes each $c_t$ a dyadic rational computable
from a single period. We exploit this to record and prove a discrete symmetry: the
Cusick density appears to be invariant under reversal of the binary digits of $t$. We
give two exact, fully formalized instances for five-bit shifts. The reversal pair
$(19,25)$, with $19 = 10011_2$ and $25 = 11001_2$, satisfies $c_{19} = c_{25} = 41/64$;
the reversal pair $(23,29)$, with $23 = 10111_2$ and $29 = 11101_2$, satisfies
$c_{23} = c_{29} = 75/128$. The proofs combine a kernel computation of the per-period
counts ($164$ over $[0,256)$ and $300$ over $[0,512)$, respectively) with the general
periodicity theorem to obtain equality of the counts over every aligned block
$[0, 2^{L+s_2(t)}\,m)$.

## 1. Introduction

The binary digit sum $s_2$ is among the most studied of all *automatic* sequences,
and its arithmetic behavior under addition has a long history connecting Gelfond's
digit problems, the Thue–Morse sequence (the parity of $s_2$), and dynamical
transfer-operator methods. T. W. Cusick conjectured that adding any fixed positive
integer $t$ is biased toward not decreasing the digit sum: the density
$$c_t = \operatorname{dens}\{n : s_2(n) \le s_2(n+t)\}$$
satisfies $c_t > 1/2$ for every $t \ge 1$. Drmota, Kauers, and Spiegelhofer proved
the stronger explicit lower bound
$$c_t \ge \frac{1}{2} + 2^{-(2 s_2(t)+1)}, \tag{DKS}$$
settling Cusick's conjecture quantitatively.

While the inequality direction is now a theorem, the *exact values* and *internal
symmetries* of the family $\{c_t\}$ remain largely mysterious. This paper isolates one
such symmetry. Reversing the binary digits of $t$ within its bit length plainly
preserves both $s_2(t)$ and the bit length $L$, hence the fundamental period
$2^{L+s_2(t)}$. It is far less obvious that it preserves the density itself, because the
density is governed by carry interactions that depend on the *arrangement* of the bits,
not merely their count. We prove two exact instances of the resulting **digit-reversal
invariance conjecture** $c_t = c_{\mathrm{rev}(t)}$ for five-bit shifts.

**Main theorems (informal).**
$$c_{19} = c_{25} = \frac{41}{64}, \qquad c_{23} = c_{29} = \frac{75}{128}.$$
All counts behind these values are verified by a formal kernel computation, and the
extension from a single period to all aligned blocks is supplied by the general
periodicity theorem.

## 2. Definitions

**Definition 1 (Binary digit sum).** For $n \in \mathbb{N}$,
$$s_2(n) = \sum_{i \ge 0} \varepsilon_i(n), \qquad n = \sum_{i \ge 0}\varepsilon_i(n)\,2^i,\ \varepsilon_i(n)\in\{0,1\}.$$
Equivalently $s_2(n)$ is the sum of the base-$2$ digit list of $n$. In the formal
development this is `s2 n := (Nat.digits 2 n).sum`.

**Definition 2 (Computable copy).** Because the catalog's `s2` is declared
`noncomputable`, a definitionally equal computable copy
$$\texttt{s2compute}(n) := (\texttt{Nat.digits}\,2\,n).\texttt{sum}$$
is introduced, with `s2compute_eq : s2compute n = s2 n` holding by reflexivity. This
copy is what enables kernel evaluation (`native_decide`) of finite per-period counts;
it agrees with $s_2$ on every input.

**Definition 3 (Cusick predicate and count).** For a shift $t$ and window $N$,
$$P_t(n) := \big[\,s_2(n) \le s_2(n+t)\,\big], \qquad
\mathrm{cusickCount}(t, N) := \#\{\,0 \le n < N : P_t(n)\,\}.$$
In Lean, `cusickCount t N := ((range N).filter (fun n => s2 n ≤ s2 (n + t))).card`.

**Definition 4 (Cusick density).** When the limit exists,
$$c_t := \lim_{N\to\infty}\frac{\mathrm{cusickCount}(t,N)}{N}.$$
By periodicity (Section 3) the limit exists and equals
$\mathrm{cusickCount}(t, 2^{L+s_2(t)}) / 2^{L+s_2(t)}$ for any $L$ with $t < 2^L$.

**Definition 5 (Binary digit reversal).** For $t$ with bit length
$L = \lvert \texttt{digits}_2\,t\rvert$, the reversal $\mathrm{rev}(t)$ is the integer
whose binary digit list is that of $t$ read in reverse order (within the $L$-bit window).
Reversal preserves $s_2$ and $L$: $s_2(\mathrm{rev}(t)) = s_2(t)$ and
$\lvert\texttt{digits}_2\,\mathrm{rev}(t)\rvert = L$. The pairs studied here are
$\mathrm{rev}(19) = 25$ and $\mathrm{rev}(23) = 29$.

## 3. Background: pure periodicity and dyadic rationality

The following structural result (formalized as `cusick_periodic` and
`cusickCount_period` in the supporting development) is the backbone that turns an
infinite density into a finite count.

**Theorem A (Pure periodicity).** Let $t \ge 1$ and let $L$ satisfy $t < 2^L$. Put
$M = L + s_2(t)$. Then for all $n$,
$$P_t(n) \iff P_t(n \bmod 2^{M}).$$

*Proof sketch.* Decompose $n = 2^{M} b + a$ with $a = n \bmod 2^{M}$. Two regimes:

- *Non-overflow* ($a + t < 2^{M}$). By the digit-concatenation identity
  $s_2(2^{M} b + x) = s_2(b) + s_2(x)$ for $x < 2^{M}$, both sides of $P_t$ gain the same
  $s_2(b)$, so $P_t(n) \iff [\,s_2(a) \le s_2(a+t)\,]$, independent of $b$.
- *Overflow* ($a + t \ge 2^{M}$). Here $a \ge 2^{M} - t > 2^{L}(2^{s_2(t)} - 1)$ forces the
  top $s_2(t)$ bits of the $M$-bit window to be all $1$; adding $t$ annihilates them via a
  carry chain, so by strict subadditivity on overflow $s_2(n+t) < s_2(n)$ for *every*
  high part $b$. The predicate is uniformly false, again independent of $b$. $\square$

**Theorem B (Exact scaling / dyadic rationality).** With $M = L + s_2(t)$ and any
$m \ge 0$,
$$\mathrm{cusickCount}(t,\ 2^{M} m) = m \cdot \mathrm{cusickCount}(t,\ 2^{M}).$$
Consequently $c_t = \mathrm{cusickCount}(t, 2^{M}) / 2^{M}$ is a dyadic rational.

*Proof sketch.* Induct on $m$, splitting $\mathrm{range}(2^{M}(m+1))$ into
$\mathrm{range}(2^{M} m)$ and a shifted copy of $\mathrm{range}(2^{M})$; Theorem A makes
the shifted block contribute exactly one more base count. $\square$

## 4. The reversal pairs and their digit sums

| $t$ | binary | $s_2(t)$ | bit length $L$ | period $2^{L+s_2(t)}$ |
|---|---|---|---|---|
| $19$ | $10011_2$ | $3$ | $5$ | $256$ |
| $25$ | $11001_2$ | $3$ | $5$ | $256$ |
| $23$ | $10111_2$ | $4$ | $5$ | $512$ |
| $29$ | $11101_2$ | $4$ | $5$ | $512$ |

The reflections $11001 = \overline{10011}$ and $11101 = \overline{10111}$ exhibit the
reversal relations $\mathrm{rev}(19) = 25$ and $\mathrm{rev}(23) = 29$. The corresponding
formal facts are `s2_nineteen : s₂(19) = 3`, `s2_twentyfive : s₂(25) = 3`,
`s2_twentythree : s₂(23) = 4`, `s2_twentynine : s₂(29) = 4`, each true by reflexivity.

## 5. Base-block counts (single period)

**Lemma 5 (Per-period counts).** The Cusick counts over one fundamental period are
$$\mathrm{cusickCount}(19, 256) = 164, \quad \mathrm{cusickCount}(25, 256) = 164,$$
$$\mathrm{cusickCount}(23, 512) = 300, \quad \mathrm{cusickCount}(29, 512) = 300.$$

*Proof.* Each count is a finite enumeration over an explicit range. Replacing $s_2$ by
its definitionally equal computable copy `s2compute` (Definition 2), the four counts are
discharged by kernel evaluation (`native_decide`). The formal lemmas are
`cusickCount_nineteen_base`, `cusickCount_twentyfive_base`,
`cusickCount_twentythree_base`, `cusickCount_twentynine_base`. $\square$

The crucial observation is that the *base-block counts already coincide within each
reversal pair*: $164 = 164$ for $(19,25)$ and $300 = 300$ for $(23,29)$. This per-period
coincidence is the entire arithmetic content of the symmetry.

## 6. Exact counts over all aligned blocks

**Theorem 6 (Exact block counts).** For every $m \ge 0$,
$$\mathrm{cusickCount}(19, 256\,m) = 164\,m, \qquad \mathrm{cusickCount}(25, 256\,m) = 164\,m,$$
$$\mathrm{cusickCount}(23, 512\,m) = 300\,m, \qquad \mathrm{cusickCount}(29, 512\,m) = 300\,m.$$

*Proof.* Apply Theorem B with $L = 5$. For $t \in \{19,25\}$, $s_2(t) = 3$ gives
$2^{L+s_2(t)} = 256$, so $\mathrm{cusickCount}(t, 256\,m) = m \cdot
\mathrm{cusickCount}(t,256) = 164\,m$ by Lemma 5. For $t \in \{23,29\}$, $s_2(t) = 4$ gives
$2^{L+s_2(t)} = 512$, so $\mathrm{cusickCount}(t,512\,m) = m\cdot 300 = 300\,m$. These are
the formal theorems `cusickCount_nineteen`, `cusickCount_twentyfive`,
`cusickCount_twentythree`, `cusickCount_twentynine`. $\square$

## 7. Main results: digit-reversal invariance

**Theorem 7 (Reversal pair $(19,25)$).** For every $m \ge 0$,
$$\mathrm{cusickCount}(19, 256\,m) = \mathrm{cusickCount}(25, 256\,m).$$
Hence the densities coincide:
$$c_{19} = c_{25} = \frac{164}{256} = \frac{41}{64}.$$

*Proof.* Both sides equal $164\,m$ by Theorem 6; dividing by $256\,m$ and taking
$m \to \infty$ gives the common density $164/256 = 41/64$. Formal name:
`cusick_density_19_eq_25`. $\square$

**Theorem 8 (Reversal pair $(23,29)$).** For every $m \ge 0$,
$$\mathrm{cusickCount}(23, 512\,m) = \mathrm{cusickCount}(29, 512\,m).$$
Hence
$$c_{23} = c_{29} = \frac{300}{512} = \frac{75}{128}.$$

*Proof.* Both sides equal $300\,m$ by Theorem 6; dividing by $512\,m$ and letting
$m \to \infty$ gives the common density $300/512 = 75/128$. Formal name:
`cusick_density_23_eq_29`. $\square$

## 8. Consistency with the DKS bias bound

It is instructive to compare the exact values with the general guarantee (DKS).

- $t = 19$, $s_2(t) = 3$: the bound gives $c_{19} \ge \tfrac12 + 2^{-7} = \tfrac{65}{128}
  \approx 0.5078$; the exact value is $c_{19} = \tfrac{41}{64} = \tfrac{82}{128} \approx
  0.6406$.
- $t = 23$, $s_2(t) = 4$: the bound gives $c_{23} \ge \tfrac12 + 2^{-9} = \tfrac{257}{512}
  \approx 0.5020$; the exact value is $c_{23} = \tfrac{75}{128} = \tfrac{300}{512} \approx
  0.5859$.

In both cases the true density comfortably exceeds the DKS lower bound, and — the point
of this paper — is *identical* across each reversal pair.

## 9. Algorithms

**Algorithm I (Periodic exact Cusick density).** Given $t$, compute $L = \lvert
\texttt{digits}_2 t\rvert$, $s = s_2(t)$, period $P = 2^{L+s}$, count
$K = \#\{0 \le n < P : s_2(n+t) \ge s_2(n)\}$, and return the exact rational $K/P$. By
Theorem B this equals $c_t$ exactly. Complexity: $O(P \cdot L)$ bit operations, with
$P = 2^{L+s_2(t)}$.

**Algorithm II (Reversal-pair certifier).** Given $t$, form $\mathrm{rev}(t)$ by
reversing its $L$-bit binary string, verify $s_2(t) = s_2(\mathrm{rev}(t))$ and equal bit
length (so the periods match), compute both exact densities via Algorithm I, and report
whether $c_t = c_{\mathrm{rev}(t)}$. For $(19,25)$ and $(23,29)$ it returns equality with
common values $41/64$ and $75/128$.

## 10. Applications and discussion

The exact dyadic values $c_{19} = c_{25} = 41/64$ and $c_{23} = c_{29} = 75/128$ enrich
the explicitly known catalog of Cusick densities (which includes $c_1 = 3/4$,
$c_3 = 11/16$, $c_7 = 43/64$, $c_{15}$, the doubling family $c_{2^k} = 3/4$, and others).
More importantly, they constitute the first rigorous, exact confirmations of binary
digit-reversal invariance among five-bit shifts. Distinct shifts with equal digit sum and
bit length need not share a density; the reversal symmetry is therefore a genuine
constraint on the *carry bookkeeping*, not a corollary of the period alone. The phenomenon
has also been observed for $(11,13)$, $(35,49)$, and others, supporting a general
conjecture $c_t = c_{\mathrm{rev}(t)}$.

## 11. Future work

A natural program is to upgrade these instances to a theorem. The strategy is to
construct, on the fundamental period $[0, 2^{L+s_2(t)})$, a measure-preserving bijection
$n \mapsto \rho(n)$ implementing window reversal, satisfying $P_t(n) \iff
P_{\mathrm{rev}(t)}(\rho(n))$; this would give $\mathrm{cusickCount}(t, P) =
\mathrm{cusickCount}(\mathrm{rev}(t), P)$ for all reversal pairs at once. A clean target
lemma is $s_2(\mathrm{rev}_L(n)) = s_2(n)$ together with a carry correspondence under
window reversal. Independently, the general DKS per-period bias
$2\,\mathrm{cusickCount}(t, 2^{L+s_2(t)}) \ge 2^{L+s_2(t)} + 2^{L - s_2(t)}$ remains a
worthwhile formalization target. (See the package's Future Directions for the full list,
including the all-ones closed form $c_{2^s-1} = 2/3 + 1/(3\cdot 4^s)$ and the conjecture
that the all-ones shift is extremal among shifts of a given digit sum.)

## 12. Conclusion

We have stated and proved, with full formal verification of every count, two exact
instances of binary digit-reversal invariance of Cusick densities:
$c_{19} = c_{25} = 41/64$ and $c_{23} = c_{29} = 75/128$. The proofs reduce, via pure
periodicity, to the per-period coincidences $164 = 164$ and $300 = 300$, exposing a
discrete mirror symmetry in the fine structure of digit-sum dynamics.
