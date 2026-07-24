import StableKneserResearch.Coloring

/-!
# Cyclic stability and the stable Kneser upper coloring

This connects the packing development to the paper's cyclic notion of
`s`-stability. We represent `[n]` by natural numbers `0, ..., n-1`.
-/

namespace StableKneser

/-- A finite subset of `[0,n)` is cyclically `s`-stable when both arcs between
any two distinct selected points have length at least `s`. -/
def CyclicStable (n s : ℕ) (A : Finset ℕ) : Prop :=
  (∀ x ∈ A, x < n) ∧
  ∀ ⦃x y : ℕ⦄, x ∈ A → y ∈ A → x < y → s ≤ y - x ∧ s ≤ n + x - y

/-
Cyclic stability implies the linear gap condition.
-/
theorem CyclicStable.linearStable {n s : ℕ} {A : Finset ℕ}
    (h : CyclicStable n s A) : LinearStable s A := by
  exact fun x y hx hy hxy => by have := h.2 hx hy hxy; omega;

/-
Every member of a cyclically stable set lies in `[0,n)`.
-/
theorem CyclicStable.mem_lt {n s : ℕ} {A : Finset ℕ}
    (h : CyclicStable n s A) {x : ℕ} (hx : x ∈ A) : x < n := by
  exact h.1 x hx

/-
**Upper-bound half of the stable Kneser chromatic formula.**

When `n = r + s(k-1)`, the canonical map to `r` colors is proper on cyclically
`s`-stable `k`-sets: disjoint vertices always receive different colors.
Since `r = n - sk + s` whenever the natural-number subtraction is exact, this
is precisely the constructive upper bound in Meunier's formula.
-/
theorem cyclicStable_canonicalColor_proper
    (n s k r : ℕ) (hs : 0 < s) (hk : 0 < k) (hr : 0 < r)
    (hn : n = r + s * (k - 1))
    (A B : Finset ℕ) (hA : A.Nonempty) (hB : B.Nonempty)
    (hcardA : A.card = k) (hcardB : B.card = k)
    (hstableA : CyclicStable n s A) (hstableB : CyclicStable n s B)
    (hdisjoint : Disjoint A B) :
    canonicalColor r A hA ≠ canonicalColor r B hB := by
  apply StableKneser.canonicalColor_ne_of_disjoint s k r n hs hk hr hn A B hA hB hcardA hcardB (StableKneser.CyclicStable.linearStable hstableA) (StableKneser.CyclicStable.linearStable hstableB) (fun x hx => hstableA.1 x hx) (fun x hx => hstableB.1 x hx) hdisjoint

/-
The number of colors in the canonical construction has the paper's
algebraic form `n - s*k + s`.
-/
theorem colorCount_eq_meunier (n s k r : ℕ) (hk : 0 < k) (hsr : s ≤ r)
    (hn : n = r + s * (k - 1)) : n - s * k + s = r := by
  cases k <;> simp_all +decide [ Nat.mul_succ ] ; omega

end StableKneser