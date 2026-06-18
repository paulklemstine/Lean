Formalize a complete Lean 4 file proving that valuation profiles form a lax monoidal map from coefficient sequences with pointwise addition and ordinary Cauchy product convolution to tropical profiles with min and min-plus convolution.

Precise scope:
1. Define a structure
   AddVal (K : Type*) [CommSemiring K]
with fields
   v : K → WithTop ℤ,
   map_zero : v 0 = ⊤,
   map_mul : ∀ x y, v (x * y) = v x + v y,
   min_le_map_add : ∀ x y, min (v x) (v y) ≤ v (x + y).

2. Define
   Seq K := ℕ → K
   vprofile (val : AddVal K) (f : Seq K) : ℕ → WithTop ℤ := fun n => val.v (f n)
   cauchyConv (f g : Seq K) (n : ℕ) := ∑ k in Finset.range (n+1), f k * g (n-k)

3. Define a tropical convolution on profiles. Keep it implementation-friendly. A good choice is
   pairVal (φ ψ : ℕ → WithTop ℤ) (n k : ℕ) := φ k + ψ (n-k)
for k in range (n+1), and
   tropConv (φ ψ : ℕ → WithTop ℤ) (n : ℕ) :=
     Finset.inf' (Finset.range (n+1)) (by simp) (fun k => φ k + ψ (n-k)).
If inf' over WithTop ℤ is awkward, you may instead define the target theorem directly as a pointwise lower-bound statement
   ∀ k ≤ n, vprofile f k + vprofile g (n-k) ≤ vprofile (cauchyConv f g) n,
then derive the inf-form corollary if convenient.

4. Prove the finite-sum valuation lower-bound lemma needed for convolution. Suggested shape:
   lemma le_map_sum_of_forall_le
     (val : AddVal K) (s : Finset α) (x : α → K) (a : WithTop ℤ)
     (h : ∀ i ∈ s, a ≤ val.v (x i)) :
     a ≤ val.v (∑ i in s, x i)
This should be by Finset induction using min_le_map_add and transitivity from a ≤ b and a ≤ c to a ≤ min b c.

5. Prove the pointwise addition inequality:
   theorem vprofile_add_ge
     (val : AddVal K) (f g : Seq K) (n : ℕ) :
     min (vprofile val f n) (vprofile val g n) ≤ vprofile val (fun m => f m + g m) n
This should be immediate from min_le_map_add.

6. Prove the key termwise lower bound for Cauchy convolution:
   theorem vprofile_cauchyConv_term_le
     (val : AddVal K) (f g : Seq K) (n k : ℕ) (hk : k < n + 1) :
     vprofile val f k + vprofile val g (n-k)
       ≤ vprofile val (cauchyConv f g) n
Use that the k-th summand has valuation exactly the sum by map_mul, then apply the finite-sum lemma to the whole sum.

7. Prove the tropical/lax-monoidal convolution theorem in one of the following equivalent forms:
   (preferred strong form)
   theorem vprofile_cauchyConv_ge_tropConv
     (val : AddVal K) (f g : Seq K) (n : ℕ) :
     tropConv (vprofile val f) (vprofile val g) n ≤ vprofile val (cauchyConv f g) n
   or at minimum the pointwise family
   theorem vprofile_cauchyConv_ge_each
     (val : AddVal K) (f g : Seq K) (n k : ℕ) (hk : k ≤ n) :
     vprofile val f k + vprofile val g (n-k) ≤ vprofile val (cauchyConv f g) n.

8. Package the results in a final theorem such as
   theorem vprofile_lax_monoidal ...
combining the additive and convolution inequalities.

Important constraints:
- Produce a complete compilable file with no sorrys.
- Do not attempt the original binomially weighted convolution unless it becomes trivial after the unweighted version is complete.
- Prefer a small number of robust lemmas over ambitious abstraction.
- Include concise module docs explaining the mathematical meaning.

Mathematical intent:
This should faithfully realize the original valuation-profile/lax-monoidal idea, but in a tractable formal form. The key insight is that the real bottleneck is not the valuation axioms themselves but the reusable finite-sum lower-bound lemma; once that is formalized, the convolution theorem becomes straightforward and can later support weighted variants such as binomial convolution.