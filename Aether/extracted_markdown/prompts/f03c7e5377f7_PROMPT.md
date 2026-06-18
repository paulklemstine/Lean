Formalize exactly one self-contained Lean 4 development for the Bridges direction on valuations and tropical convolution, and do not include any Markov-basis or contingency-table material.

Goal: produce a coherent file proving a tropical lower bound for valuations of finite Cauchy convolutions.

Use the following precise plan.

1. Work over a commutative semiring `K`.
2. Define a structure
   `AddVal (K : Type*) [CommSemiring K]` with fields
   - `v : K → WithTop ℕ`
   - `map_zero : v 0 = ⊤`
   - `map_one : v 1 = 0`
   - `map_mul : ∀ x y, v (x * y) = v x + v y`
   - `min_le_map_add : ∀ x y, min (v x) (v y) ≤ v (x + y)`.
3. Define `vprofile (v : AddVal K) (a : ℕ → K) : ℕ → WithTop ℕ := fun n => v.v (a n)`.
4. Define finite Cauchy convolution
   `cauchyConv (a b : ℕ → K) (n : ℕ) : K := ∑ k in Finset.range (n+1), a k * b (n-k)`.
5. Define tropical convolution on profiles by a finite minimum over the same range. You may use either:
   - `Finset.inf' (Finset.range (n+1)) (by simp) (fun k => u k + w (n-k))`, or
   - an equivalent custom `tropConv` definition as the minimum of the nonempty finite set `range (n+1)`.
   Prefer whichever is easiest to prove with in Lean.

Main theorem to prove:
`theorem tropConv_le_vprofile_cauchyConv
  (v : AddVal K) (a b : ℕ → K) (n : ℕ) :
  tropConv (vprofile v a) (vprofile v b) n ≤ vprofile v (cauchyConv a b) n`

Required proof strategy:
- First prove a helper lemma for finite sums over a nonempty finset: if every term has valuation at least `m`, then the valuation of the sum is at least `m`. Derive this by induction on the finset using `min_le_map_add`.
- Prove termwise that for each `k ∈ Finset.range (n+1)`,
  `v.v (a k * b (n-k)) = v.v (a k) + v.v (b (n-k))`.
- Prove the tropical minimum is below each term in the range.
- Combine these to show the valuation of the convolution sum is bounded below by the tropical convolution.

Engineering constraints:
- The file must be complete and compile without `sorry`.
- Keep the development narrow and self-contained.
- Avoid introducing unnecessary abstractions such as general Laurent series, generating functions, or unrelated combinatorics.
- If `Finset.inf'` causes friction, replace it with a custom minimum-on-range definition that is provably equivalent and easier to use.
- Add a few small sanity lemmas, e.g. for `n = 0`, if they help stabilize the proof.

Deliver a clean final file whose statements all have proofs. The objective is not maximal generality; it is a finished, correct formal bridge from additive valuations to tropical lower bounds on convolution profiles.