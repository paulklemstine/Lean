import Algebra.TropicalCryptocurrency.Hash

/-!
# Universal Collisions for Finite Families of Tropical Hashes

A tropical digest with several output components evaluates the same message
against several min-plus keys.  Each component protects only one coordinate: a
coordinate attaining its minimum.  If the message dimension exceeds the number
of digest components, one coordinate lies outside all chosen minimizers.
Increasing that coordinate by any nonnegative amount leaves the entire digest
unchanged.

The principal result strengthens the two-key collision theorem to every finite
family of keys and exhibits a whole ray in every fiber.  Thus adding finitely
many parallel tropical hash components cannot restore collision resistance
unless the number of outputs is at least the message dimension.

-- !-- Lab Notes -- !--
Hypothesis: Seven conjectures were ranked by impact. (1) Every `r`-component
min-plus digest in dimension `k > r` has an unbounded collision ray;
(2) every fiber has recession dimension at least `k-r`; (3) generic fibers have
exact recession dimension `k-r`; (4) bounded-alphabet inversion has a sharp
complexity transition; (5) nonce-restricted tropical mining reduces to linear
programming; (6) nonlinear tropical circuits can yield one-way families; and
(7) generic active-coordinate patterns form a polyhedral fan.
Experiment: For each output component, one minimizing coordinate was selected.
A cardinality argument found a coordinate outside their image, and the existing
one-coordinate stability lemma was applied componentwise along a nonnegative
ray.
Analysis: Conjecture (1) survives in full generality.  The mechanism is a
pigeonhole obstruction: `r` selected minimizers cover at most `r` of the `k`
message coordinates.  This simultaneously explains the earlier two-key result
and identifies the relevant geometric recession direction.
Critique: The argument requires `r < k` and unrestricted real-valued messages.
It deliberately makes no claim when outputs are at least as numerous as inputs,
or when a nonce language or bounded alphabet prevents movement along the ray.
The stronger dimension claim (2) needs simultaneous control of several unused
coordinates and a precise notion of polyhedral dimension, so it remains open.
Synthesis: Every fiber of a finite min-plus digest with fewer outputs than input
coordinates contains an injectively parameterized nonnegative ray, yielding
infinitely many explicit collisions through every message.
-- !-- end Lab Notes -- !--
-/

noncomputable section

namespace TropicalCryptocurrency

/-- A digest obtained by evaluating a message against a finite family of
min-plus keys. -/
def tshaFamily {r k : ℕ} [Nonempty (Fin k)]
    (keys : Fin r → Fin k → ℝ) (m : Fin k → ℝ) : Fin r → ℝ :=
  fun j => tsha (keys j) m

/-- If fewer coordinates are selected than exist, some coordinate is not
selected. -/
lemma exists_fin_outside_range {r k : ℕ} (hrk : r < k) (f : Fin r → Fin k) :
    ∃ q : Fin k, ∀ j, q ≠ f j := by
  by_contra! h_contra;
  exact absurd ( Fintype.card_le_of_surjective f ( fun q ↦ by obtain ⟨ j, rfl ⟩ := h_contra q; exact ⟨ j, rfl ⟩ ) ) ( by simpa )

/-- A coordinate outside one chosen minimizer for every key may be increased by
any nonnegative amount without changing the family digest. -/
lemma tshaFamily_update_of_avoids_minimizers {r k : ℕ} [Nonempty (Fin k)]
    (keys : Fin r → Fin k → ℝ) (m : Fin k → ℝ) (p : Fin r → Fin k)
    (hp : ∀ j, m (p j) + keys j (p j) = tsha (keys j) m)
    (q : Fin k) (hq : ∀ j, q ≠ p j) (d : ℝ) (hd : 0 ≤ d) :
    tshaFamily keys (Function.update m q (m q + d)) = tshaFamily keys m := by
  funext j; exact (by
  apply tsha_update_of_other_minimizer;
  exacts [ Ne.symm ( hq j ), hp j, hd ])

/-- **Universal collision-ray theorem.** If a finite tropical digest has fewer
components than message coordinates, then the fiber through every message
contains the entire nonnegative coordinate ray obtained by increasing a single
coordinate. -/
theorem tshaFamily_universal_collision_ray {r k : ℕ} [Nonempty (Fin k)]
    (hrk : r < k) (keys : Fin r → Fin k → ℝ) (m : Fin k → ℝ) :
    ∃ q : Fin k, ∀ d : ℝ, 0 ≤ d →
      tshaFamily keys (Function.update m q (m q + d)) = tshaFamily keys m := by
  obtain ⟨p, hp⟩ : ∃ p : Fin r → Fin k, ∀ j, m (p j) + keys j (p j) = tsha (keys j) m := by
    exact ⟨ fun j => Classical.choose ( exists_coordinate_eq_tsha ( keys j ) m ), fun j => Classical.choose_spec ( exists_coordinate_eq_tsha ( keys j ) m ) ⟩;
  obtain ⟨q, hq⟩ : ∃ q : Fin k, ∀ j, q ≠ p j := by
    exact exists_fin_outside_range hrk p
  exact ⟨ q, fun d hd => tshaFamily_update_of_avoids_minimizers keys m p hp q hq d hd ⟩

/-- Every positive point on the collision ray is a message distinct from its
base point. -/
theorem tshaFamily_positive_ray_collision {r k : ℕ} [Nonempty (Fin k)]
    (hrk : r < k) (keys : Fin r → Fin k → ℝ) (m : Fin k → ℝ) :
    ∃ q : Fin k, ∀ d : ℝ, 0 < d →
      Function.update m q (m q + d) ≠ m ∧
      tshaFamily keys (Function.update m q (m q + d)) = tshaFamily keys m := by
  obtain ⟨ q, hq ⟩ := tshaFamily_universal_collision_ray hrk keys m;
  exact ⟨ q, fun d hd => ⟨ fun h => by have := congr_fun h q; norm_num at this; linarith, hq d hd.le ⟩ ⟩

/-- Distinct positive parameters give distinct messages on the collision ray,
so every fiber contains an injective copy of the positive real half-line. -/
theorem tshaFamily_collision_ray_injective {r k : ℕ} [Nonempty (Fin k)]
    (hrk : r < k) (keys : Fin r → Fin k → ℝ) (m : Fin k → ℝ) :
    ∃ q : Fin k,
      Function.Injective (fun d : {d : ℝ // 0 < d} =>
        Function.update m q (m q + d.1)) ∧
      (∀ d : {d : ℝ // 0 < d},
        tshaFamily keys (Function.update m q (m q + d.1)) = tshaFamily keys m) := by
  obtain ⟨ q, hq ⟩ := tshaFamily_positive_ray_collision hrk keys m;
  refine' ⟨ q, _, _ ⟩;
  · intro d e hde; replace hde := congr_fun hde q; aesop;
  · exact fun d => hq _ d.2 |>.2

end TropicalCryptocurrency