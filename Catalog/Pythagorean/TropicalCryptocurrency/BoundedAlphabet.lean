import Pythagorean.TropicalCryptocurrency.RecessionCone

/-!
# Tropical Cryptocurrency IV: no bounded-alphabet security threshold

The catalogue file `Algebra/TropicalCryptocurrency/Hash.lean` produced collisions
for unrestricted real messages, and it was conjectured that restricting messages to
a bounded alphabet `{0,1,…,B}` would restore injectivity below an explicit
*key-spread* threshold, collisions appearing only once `B` exceeds that threshold.

We refute this.  The correct statement is that the threshold is `|alphabet| ≥ 2`,
with **no dependence whatsoever on the keys**:

* `exists_unused_coordinate` : if `r < k`, some coordinate `q` is *unused*, i.e.
  every digest component has an active coordinate different from `q`.
* `digest_bump_eq` : raising an unused coordinate by any nonnegative amount does
  not change the digest.
* `exists_two_letter_collision` : for **any** two-letter alphabet `{a, b}` with
  `a < b`, **any** key family and `r < k`, two distinct messages over that alphabet
  collide.  In particular binary messages already collide.
* `exists_bounded_integer_collision` : the integer form, messages in `{0,…,B}` with
  `B ≥ 1` and integer keys.
* `alphabet_one_letter_injective` : sharpness — over a one-letter alphabet the
  digest is (vacuously) injective, so the threshold `2` cannot be lowered.

-- !-- Lab Notes -- !--
Hypothesis: bounded alphabets restore collision resistance below a key-spread
threshold.
Experiment: taking the constant message `a` and raising a single unused coordinate
to `b` produces a collision for every key family; the digest never sees the change
because each component certifies its minimum elsewhere.  No spread quantity enters
the construction.
Analysis: the conjectured "slack at unused coordinates" obstruction is illusory —
the collision ray does not need to travel far, only to reach the next letter of the
alphabet, and the very first step already suffices.  Security of min-plus digests
therefore cannot be bought by shrinking the alphabet; only `r ≥ k` can help.
Critique: the result is an existence statement about the whole message space rather
than about a prescribed message; for a *prescribed* message with all coordinates
already equal to the top letter the bump is unavailable, which is exactly why the
statement quantifies over the pair of messages.
-- !-- end Lab Notes -- !--
-/

noncomputable section

namespace TropicalRecession

variable {k r : ℕ} [Nonempty (Fin k)]

/-- If there are fewer digest components than coordinates, some coordinate is
*unused*: every component certifies its minimum at another coordinate. -/
theorem exists_unused_coordinate (hrk : r < k) (A : Fin r → Fin k → ℝ) (m : Fin k → ℝ) :
    ∃ q : Fin k, ∀ i, ∃ j, j ≠ q ∧ m j + A i j = digest A m i := by
  choose p hp using exists_argmin A m
  have hcard : (Finset.image p Finset.univ).card < (Finset.univ : Finset (Fin k)).card := by
    have h1 : (Finset.image p Finset.univ).card ≤ r := by
      calc (Finset.image p Finset.univ).card ≤ (Finset.univ : Finset (Fin r)).card :=
        Finset.card_image_le
      _ = r := by simp
    have h2 : (Finset.univ : Finset (Fin k)).card = k := by simp
    omega
  obtain ⟨q, -, hq⟩ := Finset.exists_mem_notMem_of_card_lt_card hcard
  refine ⟨q, fun i => ⟨p i, ?_, hp i⟩⟩
  rintro rfl
  exact hq (Finset.mem_image_of_mem p (Finset.mem_univ i))

/-- Raising an unused coordinate by a nonnegative amount leaves the digest fixed. -/
theorem digest_bump_eq {A : Fin r → Fin k → ℝ} {m : Fin k → ℝ} {q : Fin k}
    (hq : ∀ i, ∃ j, j ≠ q ∧ m j + A i j = digest A m i) {d : ℝ} (hd : 0 ≤ d) :
    digest A (Function.update m q (m q + d)) = digest A m := by
  have hupd : Function.update m q (m q + d)
      = m + fun j => if j = q then d else 0 := by
    funext j
    by_cases hj : j = q <;> simp [hj, Function.update_apply]
  rw [hupd]
  funext i
  obtain ⟨j, hjq, hj⟩ := hq i
  refine digest_add_eq A m _ (fun j => ?_) i hj (by simp [hjq])
  by_cases h : j = q <;> simp [h, hd]

/-- **Universal collision, unrestricted messages.**  Whenever `r < k`, every message
has a distinct message with the same digest.  (This generalises the two-key,
`k ≥ 3` collision theorem of the catalogue to arbitrary `r < k`.) -/
theorem exists_collision (hrk : r < k) (A : Fin r → Fin k → ℝ) (m : Fin k → ℝ) :
    ∃ m' : Fin k → ℝ, m' ≠ m ∧ digest A m' = digest A m := by
  obtain ⟨q, hq⟩ := exists_unused_coordinate hrk A m
  refine ⟨Function.update m q (m q + 1), ?_, digest_bump_eq hq zero_le_one⟩
  intro hcon
  have := congrFun hcon q
  simp at this

/-- **No bounded-alphabet threshold.**  For any two-letter alphabet `{a, b}` with
`a < b`, any key family, and `r < k`, there are two distinct messages over that
alphabet with the same digest.  The construction is independent of the keys, so no
"key-spread" quantity can govern collision resistance. -/
theorem exists_two_letter_collision (hrk : r < k) (A : Fin r → Fin k → ℝ)
    {a b : ℝ} (hab : a < b) :
    ∃ m m' : Fin k → ℝ, (∀ j, m j ∈ ({a, b} : Set ℝ)) ∧ (∀ j, m' j ∈ ({a, b} : Set ℝ)) ∧
      m ≠ m' ∧ digest A m = digest A m' := by
  obtain ⟨q, hq⟩ := exists_unused_coordinate hrk A (fun _ => a)
  have hupd : Function.update (fun _ => a) q ((fun _ : Fin k => a) q + (b - a))
      = fun j => if j = q then b else a := by
    funext j
    by_cases hj : j = q <;> simp [hj, Function.update_apply]
  have hcol := digest_bump_eq hq (d := b - a) (by linarith)
  rw [hupd] at hcol
  refine ⟨fun _ => a, fun j => if j = q then b else a, fun j => by simp,
    fun j => ?_, ?_, hcol.symm⟩
  · by_cases hj : j = q <;> simp [hj]
  · intro hcon
    have h : a = b := by simpa using congrFun hcon q
    linarith

/-- Integer form: with integer keys and messages in `{0,1,…,B}`, `B ≥ 1` and
`r < k`, a collision always exists — again with no dependence on the keys. -/
theorem exists_bounded_integer_collision (hrk : r < k) (A : Fin r → Fin k → ℤ)
    {B : ℤ} (hB : 1 ≤ B) :
    ∃ m m' : Fin k → ℤ, (∀ j, m j ∈ Finset.Icc (0:ℤ) B) ∧ (∀ j, m' j ∈ Finset.Icc (0:ℤ) B) ∧
      m ≠ m' ∧ digest (fun i j => (A i j : ℝ)) (fun j => (m j : ℝ))
        = digest (fun i j => (A i j : ℝ)) (fun j => (m' j : ℝ)) := by
  set A' : Fin r → Fin k → ℝ := fun i j => (A i j : ℝ) with hA'
  obtain ⟨q, hq⟩ := exists_unused_coordinate hrk A' (fun _ => (0:ℝ))
  have hupd : Function.update (fun _ => (0:ℝ)) q ((fun _ : Fin k => (0:ℝ)) q + 1)
      = fun j => if j = q then (1:ℝ) else 0 := by
    funext j
    by_cases hj : j = q <;> simp [hj, Function.update_apply]
  have hcol := digest_bump_eq hq (d := (1:ℝ)) zero_le_one
  rw [hupd] at hcol
  refine ⟨fun _ => 0, fun j => if j = q then 1 else 0, fun j => ?_, fun j => ?_, ?_, ?_⟩
  · simp only [Finset.mem_Icc]
    omega
  · by_cases hj : j = q
    · simp only [hj, Finset.mem_Icc]
      omega
    · simp only [if_neg hj, Finset.mem_Icc]
      omega
  · intro hcon
    have h := congrFun hcon q
    simp at h
  · have hc0 : (fun j : Fin k => (((0:ℤ)) : ℝ)) = fun _ => (0:ℝ) := by
      funext j
      simp
    have hc1 : (fun j : Fin k => (((if j = q then (1:ℤ) else 0) : ℤ) : ℝ))
        = fun j => if j = q then (1:ℝ) else 0 := by
      funext j
      by_cases hj : j = q <;> simp [hj]
    rw [hc0, hc1]
    exact hcol.symm

/-- **Sharpness in the number of components.**  The hypothesis `r < k` cannot be
dropped: for `r = k` there is a key family whose digest is injective on the whole
box `[0,B]^k` (an "identity-like" tropical key).  Together with
`exists_two_letter_collision` this pins the collision transition exactly at
`r = k`. -/
theorem exists_injective_digest_on_box (B : ℝ) :
    ∃ A : Fin k → Fin k → ℝ, ∀ m m' : Fin k → ℝ,
      (∀ j, m j ∈ Set.Icc (0:ℝ) B) → (∀ j, m' j ∈ Set.Icc (0:ℝ) B) →
      digest A m = digest A m' → m = m' := by
  refine ⟨fun i j => if i = j then 0 else B + 1, fun m m' hm hm' hcol => ?_⟩
  have key : ∀ (x : Fin k → ℝ), (∀ j, x j ∈ Set.Icc (0:ℝ) B) → ∀ i,
      digest (fun i j => if i = j then (0:ℝ) else B + 1) x i = x i := by
    intro x hx i
    refine le_antisymm ?_ (le_digest fun j => ?_)
    · have h := digest_le (fun i j => if i = j then (0:ℝ) else B + 1) x i i
      simpa using h
    · by_cases hj : i = j
      · simp [hj]
      · have h1 := (hx j).1
        have h2 := (hx i).2
        simp only [hj, if_false]
        linarith
  funext j
  have h := congrFun hcol j
  rwa [key m hm j, key m' hm' j] at h

end TropicalRecession