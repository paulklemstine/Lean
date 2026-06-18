# Future Directions: The Library of Babel

## 1. Gilbert-Varshamov Bound and Asymptotic Rates

The sphere-packing bound gives an upper bound on code size, but the
Gilbert-Varshamov bound gives a *lower* bound: there exists a code of size
at least k^n / V(n, d-1) where V is the Hamming ball volume. Together with
our `hamming_ball_card` and `sphere_packing_bound`, formalizing the GV bound
would complete the classical coding theory trifecta.

The key insight is that the GV bound follows from a greedy argument: keep
adding codewords until no more can be added without violating the distance
constraint. The ball volumes we've computed are exactly what's needed.

Why now? We have sorry-free `hamming_ball_card` and `sphere_packing_bound`.
The GV bound is the natural next step and would be the first formalization
of this result in Lean 4 / Mathlib.

## 2. Plotkin Bound via Hamming Weight Double-Counting

When the minimum distance d exceeds n/2, the sphere-packing bound becomes
trivial. The Plotkin bound fills this gap: if d > n/2, then |C| ≤ 2d/(2d-n)
for binary codes. The proof uses a beautiful double-counting argument on the
total Hamming weight of all pairwise distances.

The key insight is that ∑_{c,c' ∈ C} d(c,c') can be computed both as a sum
over pairs and as a sum over coordinates, yielding the bound. This bridges
our Hamming metric formalization with linear algebra over F_2.

Why now? The `hammingDist_book` infrastructure and triangle inequality are
in place. The Plotkin bound requires only elementary double-counting, not
the algebraic machinery of polynomial codes.

## 3. Kolmogorov Complexity via Turing Machines

Our `incompressibility_counting` theorem is the counting core of Kolmogorov
complexity, but without Turing machines. Formalizing a minimal Turing machine
model and defining K(x) = min{|p| : U(p) = x} would connect our combinatorial
results to algorithmic information theory proper.

The key insight is that once K(x) is defined, our `fraction_compressible_bound`
immediately gives |{x : K(x) < |x| - d}| ≤ 2^(|x|-d), the "most strings are
random" theorem of Kolmogorov complexity.

Why now? Lean 4 has good support for recursive function definitions. A minimal
UTM formalization (even a string rewriting system) would suffice to state K(x).

## 4. Perfect Codes Classification

Our sphere-packing bound achieves equality for "perfect codes." The classification
theorem states that the only nontrivial perfect binary codes are the Hamming codes
(parameters [2^r - 1, 2^r - r - 1, 3]) and the binary Golay code [23, 12, 7].
Formalizing that Hamming codes achieve equality in `sphere_packing_bound` would
be a clean application of our ball cardinality formula.

The key insight is that for Hamming codes, k^n / V(n,t) is exactly an integer
(= 2^{n-r}), which is equivalent to the ball volumes partitioning the space.
This connects combinatorial coding theory to finite geometry (projective spaces
over F_2).

Why now? We have the exact ball cardinality formula. Verifying that 2^n = 2^{n-r} * V(n,1)
for n = 2^r - 1 is a concrete numerical identity that our framework can check.

## 5. Metric Entropy and Covering Numbers

The Hamming ball cardinality determines the ε-covering number N(ε) of the Library:
the minimum number of balls of radius ε needed to cover the space. This connects
to metric entropy H(ε) = log N(ε), a fundamental concept in approximation theory.

The key insight is that N(ε) = ⌈k^n / V(n, ε)⌉ for the Hamming metric (by a
simple volume argument), giving an exact formula rather than just bounds. This
bridges discrete combinatorics with continuous approximation theory.

Why now? The `hamming_ball_card_full` result (ball of radius n covers everything)
and the exact ball cardinality formula provide the two ingredients needed. This
would be a novel formalized bridge between coding theory and functional analysis.
