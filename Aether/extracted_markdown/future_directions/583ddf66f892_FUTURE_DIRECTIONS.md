# Future Directions: Collatz Dynamics and Proof-Theoretic Barriers

## What We Proved

This cycle formalized a complete framework connecting Collatz dynamics to 2-adic structure,
with **zero sorry** across two files and **12 fully verified theorems**. The crown jewel is
the **parity determinism theorem**: `n mod 2^k` determines the first `k` parities of the
Collatz orbit, which is equivalent to 2-adic continuity of the Collatz map. Supporting this
are the power-of-two halvings theorem, one-step congruence preservation, multi-step congruence
propagation, and concrete contraction certificates for residue classes mod 4, 8, and 16.

---

## Direction 1: 2-Adic Continuity to Density Bounds

Our `parity_determined_by_residue` theorem is essentially a discrete version of 2-adic
continuity. The key insight is that extending this to the full 2-adic integers ℤ₂ and
proving Lipschitz continuity of the Collatz map would enable analytic methods (Mahler
series, p-adic measures) to attack density bounds.

**Conjecture**: The Collatz map T extends to a 1-Lipschitz function T: ℤ₂ → ℤ₂ in the
2-adic metric, and for any n ∈ ℕ, the odd density lim sup_{k→∞} oddCount(n,k)/k < 0.45.

**Test**: Formalize `Collatz.step` as a map on `ZMod (2^k)` for each k, prove compatibility
with the projective limit structure, then construct the ℤ₂ extension. Compute empirical
odd densities for n ≤ 10^6 to verify the 0.45 bound computationally.

**Why now?** Our `iter_congruence` theorem already provides the key compatibility condition:
congruence mod 2^(k+1) is preserved (with controlled loss) through iteration. This is precisely
the data needed to define the projective limit. Mathlib has `PadicInt` and projective limit
infrastructure that could be leveraged directly.

---

## Direction 2: Universality Threshold for Generalized Collatz Systems

Our GCS framework (`GCS` structure with divisibility conditions) is ready for studying
computational power as a function of modulus. The key insight is that Conway proved
undecidability for *some* GCS, but the threshold modulus is unknown — determining it
would tell us exactly how "far" standard Collatz (modulus 2) is from Turing completeness.

**Conjecture**: GCS with modulus ≤ 5 have decidable orbit behavior. Modulus 6 suffices
for Turing-completeness via simulation of 2-counter machines.

**Test**: For modulus 2 (standard Collatz), prove that `standardCollatz.step` has bounded
growth ratio (our `odd_even_pair_bound` gives factor ≤ 2 per odd-even pair). For modulus 6,
explicitly construct a GCS simulating a universal 2-counter machine and formalize the
reduction.

**Why now?** The GCS framework and `standardCollatz` definition are in place. The growth
bound `odd_even_pair_bound` already constrains modulus-2 systems. Extending to modulus 3-5
requires similar growth analysis with more residue classes — tedious but tractable.

---

## Direction 3: Effective Contraction Certificates via Deeper Residue Analysis

Our mod-4, mod-8, and mod-16 contraction theorems show that deeper residue analysis yields
stronger contraction guarantees. The key insight is that for n ≡ 0 (mod 2^k), we get k
guaranteed halving steps, giving contraction by factor 2^k — but the question is what
happens *after* those halvings.

**Conjecture**: For every ε > 0, there exists K such that for n ≡ 0 (mod 2^K), the orbit
reaches a value < n^ε within O(K) steps. More precisely, step^[2K](n) < n^(1/2) for
n ≡ 0 (mod 2^K) with K = ⌈2 log₂ n⌉.

**Test**: Prove the bound for K = 4 (mod 16) using `mod16_four_step_value` and verify
step^[8](n) < √n for n ≡ 0 mod 16 with n large enough. Extend to K = 5, 6 by computing
the orbit segments explicitly.

**Why now?** We have `power_of_two_halvings` giving the first K halvings exactly, and
`odd_even_pair_bound` bounding the growth of subsequent odd steps. The missing piece is
a careful accounting of how many odd steps can occur in the "rebound" after the initial
halvings — our `odd_followed_by_even` theorem constrains this to at most half the steps.

---

## Direction 4: Collatz Independence via Encoding Goodstein Sequences

The bounded-universal gap (each ∃k, step^[k](n)=1 is decidable, but ∀n is not known to be)
mirrors the structure of PA-independent statements. The key insight is that Goodstein sequences
— which are PA-independent but provably terminating in second-order arithmetic — have a
similar "local descent, global opacity" structure to Collatz orbits.

**Conjecture**: There exists a GCS with modulus ≤ 10 whose halting problem on input 1 is
independent of PA, constructed by encoding a Goodstein-like base-change operation as
affine residue-class maps.

**Test**: Formalize the Goodstein sequence G(n) for small n in our GCS framework. The
base-change operation b → b+1 in hereditary base representation can be approximated by
a finite set of affine maps on residue classes. Verify that the encoding preserves the
ordinal descent property (ε₀-induction) that makes Goodstein PA-independent.

**Why now?** Our GCS divisibility conditions (`div_cond`) ensure that affine maps produce
natural numbers, which is exactly the constraint needed for a valid encoding. The formal
framework handles the "well-definedness" boilerplate automatically.

---

## Direction 5: Tropical Collatz Drift and Stopping Time Distribution

Taking logarithms of Collatz iterates converts multiplicative dynamics to additive, revealing
a random-walk-like structure. The key insight is that our `odd_even_pair_bound` (factor ≤ 2
per odd-even pair) and `mod4_contraction` (factor 1/4 per even-even pair) translate to
bounded step sizes in log space, making the orbit amenable to drift analysis.

**Conjecture**: The log₂-orbit (log₂(step^[k](n)))_k behaves as a random walk with negative
drift d = p·log₂(3) + (1-p)·log₂(1/2) where p ≈ log(2)/log(3) · (1/2). For "generic" n,
the stopping time (first k with step^[k](n) = 1) is Θ(log(n)²).

**Test**: Define `tropicalOrbit (n k : ℕ) : ℝ := Real.log (step^[k] n) / Real.log 2` and
prove that the one-step increment is bounded: for odd steps, the increment is
log₂(3) + O(1/n) ≈ 1.585; for even steps, exactly -1. Use `odd_followed_by_even` to show
the drift per two-step pair is at most log₂(3) - 1 ≈ 0.585, and per three steps (when
preceded by an even step) is at most log₂(3) - 2 ≈ -0.415.

**Why now?** The `oddCount` and `evenCount` functions are formalized and satisfy
`odd_even_partition`. The tropical drift is directly computable from these counts.
Real.log is available in Mathlib, making the formalization straightforward.
