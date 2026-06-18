Formalize a clean, self-contained bridge theorem from coefficient sequences with valuation to tropical lower bounds, avoiding the overly broad and previously malformed species narrative.

Target file: Catalog/Bridges/SpeciesTropicalValuation.lean

Primary goal:
Build a verified Lean development around the following concrete objects.

1. Define a structure or reuse an existing one for an additive nonarchimedean valuation
   v : K → WithTop ℤ or WithTop ℕ∞
   on a commutative semiring/ring K, with at least the lemmas
   - v 0 = ⊤
   - v (x * y) = v x + v y
   - min (v x) (v y) ≤ v (x + y)
   If an existing valuation API in the catalog or Mathlib is awkward, define a small local structure with exactly the fields needed.

2. For sequences a : ℕ → K, define the valuation profile
   vprofile (a : ℕ → K) : ℕ → WithTop ℤ := fun n => v (a n)
   or the analogous ℕ∞ version.

3. Define tropical convolution on profiles:
   tropConv (u w : ℕ → T) (n : ℕ) := ⨅ i : Fin (n+1), (u i) + (w (n - i))
   or an equivalent finite-inf formulation over Finset.range (n+1).
   Choose the formulation that is easiest to prove against.

4. Define ordinary Cauchy convolution on sequences:
   cauchyConv (a b : ℕ → K) (n : ℕ) := ∑ i in Finset.range (n+1), a i * b (n - i)

5. Prove the core lower-bound theorem:
   tropConv (vprofile v a) (vprofile v b) n ≤ vprofile v (cauchyConv a b) n.
   Suggested proof strategy:
   - prove each summand has valuation exactly v(a i)+v(b(n-i));
   - prove the infimum is ≤ each summand valuation;
   - use a finite-sum valuation lower bound lemma obtained by induction from the ultrametric inequality.

6. Also prove the simpler coefficientwise sum law:
   min (vprofile v a n) (vprofile v b n) ≤ vprofile v (fun k => a k + b k) n.

7. Optional extension only if supported by existing catalog definitions:
   define or reuse binomial/species convolution
   binConv (a b : ℕ → K) (n) := ∑ i in Finset.range (n+1), (Nat.choose n i : K) * a i * b (n-i)
   and prove
   tropConv (vprofile v a) (vprofile v b) n ≤ vprofile v (binConv a b) n
   assuming a lemma v (m : K) ≥ 0 for all naturals m. If this extension becomes technically expensive, prioritize the plain Cauchy theorem and state the binomial version as a TODO.

8. Keep the file coherent and minimal. Do not mix in unrelated material. Every declaration should have a complete proof. No placeholders, no corrupted snippets, no unrelated theorems.

9. In comments/docstrings, explain the species motivation carefully but modestly: these are coefficientwise tropical lower bounds, and species/binomial convolution is only a specialization if the relevant catalog definitions are available.

Deliverables:
- A single sorry-free Lean file with the above definitions and theorem proofs.
- Theorems should be named predictably, e.g. AddVal.v_sum_ge, AddVal.v_finset_sum_ge, vprofile_cauchyConv_ge, and if completed vprofile_binConv_ge.
- Prefer FINAL catalog foundations where available.

Important scoping decision:
If the species-side APIs are not stable enough, do NOT force a functorial or categorical statement. Formalize the sequence-level valuation/tropical bridge first; that is the mathematically precise kernel that was missing in the prior attempt.