# Future Directions: Finite-State Compression Criteria for Transcendence

## Hypothesis 1: Sofic Transcendence Hypothesis

**Conjecture.** Every irrational real number whose base-*b* digit sequence lies in a minimal aperiodic sofic shift of linear factor complexity is transcendental.

**Why it should be true.** Sofic shifts are quotients of shifts of finite type, and their factor complexity is at most linear (bounded by the number of vertices in the minimal right-resolving presentation times *m*). The Adamczewski–Bugeaud criterion states that algebraic irrational reals must have factor complexity growing faster than any linear function. Hence sofic shifts, being confined to linear complexity, should be incompatible with algebraic irrationality — unless the sequence is eventually periodic (which is excluded by the aperiodicity assumption).

**Test.** Formalize the definition of a sofic shift in Lean 4 using labeled directed graphs. Prove that sequences in sofic shifts have at most linear factor complexity (this requires bounding the number of paths of length *m* in the presentation graph). Then apply the formal transcendence criterion from `transcendental_of_nonperiodic_linear_complexity`.

**Refutation.** This would be refuted by constructing an algebraic irrational whose digit expansion lies in an aperiodic sofic shift. By the Adamczewski–Bugeaud theorem, this is impossible, so refutation would require disproving AB — a dramatic development in number theory.

**Impact.** Would unify the transcendence criterion with symbolic dynamics, making every minimal aperiodic sofic subshift a "transcendence factory."

---

## Hypothesis 2: Finite-State Compression Gap Hypothesis

**Conjecture.** There exists a constant *c* > 0 such that for any algebraic irrational *x* with base-*b* expansion *a*, the finite-state description complexity satisfies K_FS(a|_N) ≥ c·N for infinitely many *N*.

Here K_FS(a|_N) is the minimum number of states in a deterministic finite automaton that can reproduce the length-*N* prefix of *a*.

**Why it should be true.** Algebraic irrational digit expansions exhibit enough irregularity (by the Ridout/Schmidt subspace theorem) that no finite-state machine with fewer than Ω(N) states can describe them. The regularity of algebraic numbers' continued fraction expansions does not transfer to base-*b* digits in a way that allows finite-state compression. In contrast, automatic sequences have K_FS(a|_N) = O(1).

**Test.** Define K_FS formally using `fsComplexity` from the Lean file. Compute K_FS(a|_N) numerically for the digits of √2, ∛2, and the golden ratio in various bases. If the complexity grows linearly, the hypothesis is supported. Attempt to prove a lower bound using the formal connection: if K_FS(a|_N) = o(N) then linear factor complexity holds, which by AB would force eventual periodicity.

**Refutation.** Finding an algebraic irrational *x* with K_FS(a|_N) = o(N) for all *N* would refute this. By the chain of implications (bounded K_FS → linear factor complexity → eventually periodic for algebraic irrationals), this is again equivalent to contradicting AB.

**Impact.** Would establish a quantitative information-theoretic barrier to algebraic irrationality, opening a new interface between descriptional complexity and Diophantine approximation.

---

## Hypothesis 3: Transducer-Normality Exclusion Hypothesis

**Conjecture.** No nonperiodic finite-state transducer-generated real number (in the sense of having linear factor complexity) is normal in the output base.

**Why it should be true.** A normal number in base *b* has factor complexity p(m) = b^m (every length-*m* word appears with the same frequency). But linear factor complexity p(m) ≤ C·m + D grows much slower than b^m for b ≥ 2. Since normal numbers have maximal complexity while finite-state-generated sequences have minimal (linear) complexity, the two classes should be disjoint for nonperiodic sequences.

**Test.** This is provable directly from the definitions: show that if p(m) ≤ C·m + D for all m ≥ 1, then p(m) < b^m for sufficiently large m (which holds for any b ≥ 2 and linear bound), hence the sequence is not normal. Formalize this comparison in Lean.

**Refutation.** Would require a sequence with linear factor complexity that is nonetheless normal — contradicting the complexity comparison. This is mathematically impossible, making this hypothesis a theorem-in-waiting.

**Impact.** Provides a clean separation theorem: finite-state-generated reals and normal reals occupy complementary regions of the complexity spectrum. Combined with the conjecture that algebraic irrationals are normal (Borel's conjecture), this would give an independent route to transcendence.

---

## Hypothesis 4: Cobham-Plus-Transducer Rigidity Hypothesis

**Conjecture.** If a real number *x* ∈ (0,1) has digit expansion with linear factor complexity simultaneously in multiplicatively independent bases *k* and *ℓ* (i.e., log k / log ℓ ∉ ℚ), and *x* is irrational, then *x* is transcendental with the stronger conclusion that its digit shift orbit {σ^n(x) : n ≥ 0} is dense in [0,1].

**Why it should be true.** By Cobham's theorem, a sequence that is both *k*-automatic and *ℓ*-automatic for multiplicatively independent *k, ℓ* must be eventually periodic. The linear factor complexity condition generalizes automaticity. If the digit expansion has low complexity in both bases simultaneously, the sequence is severely constrained — it lives in the intersection of two "thin" sets. Algebraic irrationals are conjectured to have maximal complexity in every base, so being in both low-complexity classes should force periodicity or transcendence.

**Test.** 
1. Formalize multiplicative independence of bases.
2. State the two-base linear complexity condition.
3. Attempt to prove that two-base linear complexity forces eventual periodicity (a generalized Cobham theorem).
4. If that succeeds, transcendence follows from AB in either base.

**Refutation.** Constructing an algebraic irrational with linear factor complexity in two multiplicatively independent bases would refute this. By the AB criterion applied in each base, such a number would need to be eventually periodic in each base — but a number eventually periodic in both base *k* and base *ℓ* for multiplicatively independent *k, ℓ* must be rational (by a theorem of Cobham/Semenov). So refutation would require the number to be irrational AND rational simultaneously — impossible.

**Impact.** Would extend the Cobham–Adamczewski framework to a two-base setting, dramatically strengthening the certified transcendence frontier.

---

## Hypothesis 5: Algebraic Obstruction by Return Words Hypothesis

**Conjecture.** If the digit expansion of a real number *x* in base *b* has uniformly bounded return-word complexity — meaning there exists a constant *R* such that every factor has at most *R* distinct return words — then *x* is either rational or transcendental.

**Why it should be true.** Uniformly bounded return-word complexity implies linear factor complexity (by the structure theorem for sequences with bounded return words). Combined with the AB criterion, this means algebraic irrationals cannot have bounded return words. The return-word structure theorem (Durand, 1998) shows that bounded return words characterize linearly recurrent sequences, which include all primitive substitutive sequences. So the hypothesis is that the class of linearly recurrent sequences is disjoint from algebraic irrationals.

**Test.**
1. Define return words formally: a return word to a factor *w* is a factor *u* such that *uw* begins with *w* and *u* contains no other occurrence of *w*.
2. Prove that bounded return-word complexity implies linear factor complexity. (This is the Durand theorem.)
3. Apply the formal transcendence criterion.

For computational testing: verify that the first 10^6 digits of √2 and ∛2 in base 10 have unbounded return-word complexity (growing with factor length), while the Thue-Morse and Fibonacci sequences have bounded return-word complexity.

**Refutation.** Finding an algebraic irrational with bounded return words. By the chain of implications (bounded returns → linear complexity → eventually periodic for algebraic, by AB), this is equivalent to an algebraic irrational being eventually periodic — contradiction.

**Impact.** Would provide a purely combinatorial criterion for transcendence, avoiding the explicit mention of factor complexity. The return-word condition is often easier to verify in practice than a factor complexity bound, making it a more "user-friendly" transcendence test.
