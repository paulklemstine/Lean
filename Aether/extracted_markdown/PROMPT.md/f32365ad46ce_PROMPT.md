Formalize a complete, self-contained Lean 4 file (no sorries, no incomplete proofs) establishing the bridge from additive nonarchimedean valuations to tropical convolution lower bounds. The file must compile cleanly.

## Definitions Required

1. `structure AddVal (K : Type*) [CommSemiring K] where`
   - `v : K → WithTop ℤ`
   - `map_zero : v 0 = ⊤`
   - `map_mul : ∀ x y, v (x * y) = v x + v y`
   - `min_le_map_add : ∀ x y, min (v x) (v y) ≤ v (x + y)`

2. `def vprofile {K : Type*} [CommSemiring K] (av : AddVal K) (a : ℕ → K) : ℕ → WithTop ℤ := fun n => av.v (a n)`

3. `def tropConv (u w : ℕ → WithTop ℤ) : ℕ → WithTop ℤ := fun n => ⨅ i ∈ Finset.range (n+1), u i + w (n - i)`

4. `def cauchyConv {K : Type*} [CommSemiring K] (a b : ℕ → K) : ℕ → K := fun n => ∑ i ∈ Finset.range (n+1), a i * b (n - i)`

5. `def binConv {K : Type*} [CommSemiring K] (a b : ℕ → K) : ℕ → K := fun n => ∑ i ∈ Finset.range (n+1), (n.choose i : K) * a i * b (n - i)`

## Key Helper Lemma

Prove `lemma v_finset_sum_ge {K : Type*} [CommSemiring K] {av : AddVal K} {s : Finset ℕ} {f : ℕ → K} (h : ∀ i ∈ s, av.v (f i) ≥ w i) : av.v (∑ i ∈ s, f i) ≥ ⨅ i ∈ s, w i` by induction on `s` using `Finset.induction`, using `min_le_map_add` for the inductive step and the fact that `min a b ≤ a ⊔ b ≤ a + b` in `WithTop ℤ` (note: `⨅` over a finset is the iInf/minimum).

## Main Theorems

1. `theorem vprofile_cauchyConv_ge {K : Type*} [CommSemiring K] (av : AddVal K) (a b : ℕ → K) (n : ℕ) : vprofile av (cauchyConv a b) n ≥ tropConv (vprofile av a) (vprofile av b) n`
   Proof: Unfold definitions, apply `v_finset_sum_ge` with the bound `av.v (a i * b (n-i)) = av.v (a i) + av.v (b (n-i))` using `map_mul`.

2. `theorem vprofile_binConv_ge {K : Type*} [CommSemiring K] (av : AddVal K) (a b : ℕ → K) (h : ∀ n, av.v (n : K) ≥ 0) (n : ℕ) : vprofile av (binConv a b) n ≥ tropConv (vprofile av a) (vprofile av b) n`
   Proof: Similar to (1) but with extra term `av.v (n.choose i : K) ≥ 0` from hypothesis `h`, using `map_mul` and the fact that `0 + x = x` and `v(x) + 0 = v(x)` in `WithTop ℤ`.

## Critical Requirements
- Every proof body must be COMPLETE, no `:= by sorry` or truncated proofs
- The file must import only `Mathlib.Data.Nat.Choose.Basic` and `Mathlib.Algebra.Order.WithTop`
- No unrelated content (no IdentitySystem, no contractible material)
- Use `WithTop ℤ` with its lattice structure (iInf, min, etc.)
- The iInf over finset is available via `Finset.iInf` or direct computation