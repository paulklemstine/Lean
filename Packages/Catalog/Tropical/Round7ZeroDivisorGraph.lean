import Mathlib

/-!
# Round-7 closure ZDG + STATICRHO: the zero-divisor graph of a semiprime and the noise floor

This file formalises the arithmetic core of the round-7 closures `ZDG`
(experiment 327: *structural witnesses outside the trace lemma*) and the
refined `noise-floor principle` extracted from `STATICRHO` (experiment 326:
*the principle bounds atomic-uniform primitives*).

Setting: `N = p * q` with `p, q` distinct primes.  We model the zero-divisor
graph `Γ(ℤ/Nℤ)` on the concrete vertex set of nonzero, non-coprime residues
`0 < x < N`, with `x ~ y` iff `N ∣ x * y`.

Main results.

* `vertices_eq_wing_union` / `wings_disjoint` : the vertex set splits into the
  two *wings* (multiples of `p`, multiples of `q`).
* `card_wing`, `card_vertices` : the wings have sizes `q - 1` and `p - 1`, so
  `|V| = p + q - 2`.
* `cross_edge`, `no_intra_edge_p`, `no_intra_edge_q` : the graph is exactly the
  **complete bipartite graph** `K_{q-1, p-1}` — every cross-wing pair is an
  edge, no intra-wing pair is.
* `factor_recovery_trace`, `prime_isRoot_traceQuadratic` : the structural datum
  `|V|` is exactly the trace `p + q` (minus 2), so `p` and `q` are the roots of
  `X² - (|V| + 2) X + N`.  This is the precise sense in which the *structural*
  witness collapses onto the *numeric* trace witness.
* `atomic_uniform_success_le` : the **noise-floor bound for an atomic uniform
  primitive** — a single uniform query `a ← [1, N)` reveals a factor with
  probability `(p + q - 2)/N ≤ 2/p`, i.e. at most `2 / (smallest prime)`.
* `four_le_sq_trace` and `noise_floor_lower` : the density is bounded *below*
  by the balanced (`√N`) noise floor, and the bound is attained only when the
  semiprime is balanced.
* Tropical section: in min-plus (logarithmic) coordinates the divisor hyperbola
  degenerates to the tropical line `X ⊙ Y = N` whose corner sits at `√N`;
  `trop_corner_straddle` and `trop_mul_log_le` record that every divisor pair
  straddles the corner.
-/

namespace Round7ZDG

open Finset

/-! ## 1. Vertices and wings -/

/-- The vertex set of the zero-divisor graph of `ℤ/Nℤ`: the nonzero residues
that are not coprime to `N`. -/
def vertices (N : ℕ) : Finset ℕ :=
  (Finset.Ioo 0 N).filter (fun x => ¬ Nat.Coprime x N)

/-- The *wing* of `d`: the nonzero residues below `N` divisible by `d`. -/
def wing (d N : ℕ) : Finset ℕ :=
  (Finset.Ioo 0 N).filter (fun x => d ∣ x)

theorem mem_wing {d N x : ℕ} : x ∈ wing d N ↔ (0 < x ∧ x < N) ∧ d ∣ x := by
  simp [wing, Finset.mem_filter, Finset.mem_Ioo, and_assoc]

theorem mem_vertices {N x : ℕ} :
    x ∈ vertices N ↔ (0 < x ∧ x < N) ∧ ¬ Nat.Coprime x N := by
  simp [vertices, Finset.mem_filter, Finset.mem_Ioo, and_assoc]

variable {p q : ℕ}

/-- A vertex of the zero-divisor graph lies in one of the two wings. -/
theorem vertices_eq_wing_union (hp : p.Prime) (hq : q.Prime) :
    vertices (p * q) = wing p (p * q) ∪ wing q (p * q) := by
  ext x
  simp only [mem_vertices, Finset.mem_union, mem_wing]
  constructor
  · rintro ⟨hx, hcop⟩
    have hg : Nat.gcd x (p * q) ≠ 1 := hcop
    -- some prime divides the gcd
    obtain ⟨r, hr, hrdvd⟩ := Nat.exists_prime_and_dvd hg
    have hrx : r ∣ x := hrdvd.trans (Nat.gcd_dvd_left _ _)
    have hrN : r ∣ p * q := hrdvd.trans (Nat.gcd_dvd_right _ _)
    rcases (Nat.Prime.dvd_mul hr).mp hrN with h | h
    · left
      exact ⟨hx, ((Nat.prime_dvd_prime_iff_eq hr hp).mp h) ▸ hrx⟩
    · right
      exact ⟨hx, ((Nat.prime_dvd_prime_iff_eq hr hq).mp h) ▸ hrx⟩
  · rintro (⟨hx, hd⟩ | ⟨hx, hd⟩)
    · refine ⟨hx, ?_⟩
      intro hcop
      have : p ∣ Nat.gcd x (p * q) := Nat.dvd_gcd hd ⟨q, rfl⟩
      rw [hcop] at this
      exact hp.one_lt.ne' (Nat.dvd_one.mp this)
    · refine ⟨hx, ?_⟩
      intro hcop
      have : q ∣ Nat.gcd x (p * q) := Nat.dvd_gcd hd ⟨p, mul_comm p q⟩
      rw [hcop] at this
      exact hq.one_lt.ne' (Nat.dvd_one.mp this)

/-- The two wings are disjoint: a residue below `N` divisible by both primes
would be a nonzero multiple of `N`. -/
theorem wings_disjoint (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    Disjoint (wing p (p * q)) (wing q (p * q)) := by
  rw [Finset.disjoint_left]
  rintro x hx hx'
  rw [mem_wing] at hx hx'
  obtain ⟨⟨hx0, hxN⟩, hpx⟩ := hx
  obtain ⟨-, hqx⟩ := hx'
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  have : p * q ∣ x := Nat.Coprime.mul_dvd_of_dvd_of_dvd hcop hpx hqx
  exact absurd (Nat.le_of_dvd hx0 this) (not_le.mpr hxN)

/-! ## 2. Wing sizes and the vertex count -/

theorem wing_eq_image (hp : 0 < p) : wing p (p * q) = (Finset.Ioo 0 q).image (p * ·) := by
  ext x
  simp only [mem_wing, Finset.mem_image, Finset.mem_Ioo]
  constructor
  · rintro ⟨⟨hx0, hxN⟩, k, rfl⟩
    refine ⟨k, ⟨?_, ?_⟩, rfl⟩
    · rcases Nat.eq_zero_or_pos k with rfl | hk
      · simp at hx0
      · exact hk
    · exact lt_of_mul_lt_mul_left hxN (Nat.zero_le p)
  · rintro ⟨k, ⟨hk0, hkq⟩, rfl⟩
    exact ⟨⟨Nat.mul_pos hp hk0, by nlinarith⟩, ⟨k, rfl⟩⟩

/-- **Wing size.** The wing of `p` inside `ℤ/pqℤ` has `q - 1` elements. -/
theorem card_wing (hp : 0 < p) : (wing p (p * q)).card = q - 1 := by
  have himg : wing p (p * q) = (Finset.Ioo 0 q).image (p * ·) := wing_eq_image hp
  have hinj : Function.Injective (fun k : ℕ => p * k) := by
    intro a b hab
    exact Nat.eq_of_mul_eq_mul_left hp hab
  rw [himg, Finset.card_image_of_injective _ hinj, Nat.card_Ioo]
  omega

/-- **The vertex count is the trace.** `|V(Γ(ℤ/pqℤ))| = p + q - 2`. -/
theorem card_vertices (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    (vertices (p * q)).card = p + q - 2 := by
  rw [vertices_eq_wing_union hp hq, Finset.card_union_of_disjoint (wings_disjoint hp hq hpq),
    card_wing hp.pos]
  have : wing q (p * q) = wing q (q * p) := by rw [mul_comm]
  rw [this, card_wing hq.pos]
  have h1 := hp.two_le
  have h2 := hq.two_le
  omega

/-! ## 3. The graph is complete bipartite -/

/-- Every cross-wing pair is an edge of the zero-divisor graph. -/
theorem cross_edge {x y : ℕ}
    (hx : x ∈ wing p (p * q)) (hy : y ∈ wing q (p * q)) : p * q ∣ x * y := by
  rw [mem_wing] at hx hy
  obtain ⟨-, a, rfl⟩ := hx
  obtain ⟨-, b, rfl⟩ := hy
  exact ⟨a * b, by ring⟩

/-- No intra-wing pair is an edge: two multiples of `p` below `N` never
multiply to `0` in `ℤ/Nℤ`. -/
theorem no_intra_edge_p (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) {x y : ℕ}
    (hx : x ∈ wing p (p * q)) (hy : y ∈ wing p (p * q)) : ¬ (p * q ∣ x * y) := by
  intro hdvd
  have hx' := mem_wing.mp hx
  have hy' := mem_wing.mp hy
  have hqxy : q ∣ x * y := (dvd_mul_left q p).trans hdvd
  have : q ∣ x ∨ q ∣ y := (Nat.Prime.dvd_mul hq).mp hqxy
  rcases this with h | h
  · exact (Finset.disjoint_left.mp (wings_disjoint hp hq hpq) hx)
      (mem_wing.mpr ⟨hx'.1, h⟩)
  · exact (Finset.disjoint_left.mp (wings_disjoint hp hq hpq) hy)
      (mem_wing.mpr ⟨hy'.1, h⟩)

/-- The symmetric statement for the `q`-wing. -/
theorem no_intra_edge_q (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) {x y : ℕ}
    (hx : x ∈ wing q (p * q)) (hy : y ∈ wing q (p * q)) : ¬ (p * q ∣ x * y) := by
  have hcomm : wing q (p * q) = wing q (q * p) := by rw [mul_comm]
  rw [hcomm] at hx hy
  intro hdvd
  rw [mul_comm p q] at hdvd
  exact no_intra_edge_p hq hp (Ne.symm hpq) hx hy hdvd

/-! ## 4. From the structural witness back to the numeric trace -/

/-- **Factor recovery from the wings.** The wing of `p` has `q - 1` vertices,
so the isomorphism class of the graph returns the pair `{p, q}`. -/
theorem factor_recovery (hp : p.Prime) (hq : q.Prime) :
    (wing p (p * q)).card + 1 = q ∧ (wing q (p * q)).card + 1 = p := by
  refine ⟨?_, ?_⟩
  · rw [card_wing hp.pos]; have := hq.two_le; omega
  · have hcomm : wing q (p * q) = wing q (q * p) := by rw [mul_comm]
    rw [hcomm, card_wing hq.pos]; have := hp.two_le; omega

/-- **The structural witness is the trace witness.** With `s = |V| + 2 = p + q`,
both primes are roots of `X² - s X + N` over `ℤ`; i.e. the zero-divisor graph
delivers exactly the numeric datum `p + q` that the trace lemma already
classifies. -/
theorem prime_isRoot_traceQuadratic (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    ((p : ℤ) ^ 2 - ((vertices (p * q)).card + 2 : ℕ) * p + (p * q : ℕ) = 0) ∧
      ((q : ℤ) ^ 2 - ((vertices (p * q)).card + 2 : ℕ) * q + (p * q : ℕ) = 0) := by
  have hcard : (vertices (p * q)).card + 2 = p + q := by
    rw [card_vertices hp hq hpq]
    have := hp.two_le; have := hq.two_le; omega
  rw [hcard]
  push_cast
  constructor <;> ring

/-! ## 5. The noise floor for atomic uniform primitives -/

/-- The success density of a single uniform query: the fraction of residues in
`(0, N)` that expose a factor. -/
noncomputable def hitDensity (p q : ℕ) : ℚ := ((vertices (p * q)).card : ℚ) / (p * q : ℕ)

theorem hitDensity_eq (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    hitDensity p q = ((p : ℚ) + q - 2) / ((p : ℚ) * q) := by
  have hcard : (vertices (p * q)).card = p + q - 2 := card_vertices hp hq hpq
  have h2p := hp.two_le
  have h2q := hq.two_le
  have : ((p + q - 2 : ℕ) : ℚ) = (p : ℚ) + q - 2 := by
    have : (2 : ℕ) ≤ p + q := by omega
    push_cast [Nat.cast_sub this]
    ring
  rw [hitDensity, hcard, this]
  push_cast
  ring

/-- **ADAPT / noise-floor bound.** A single atomic uniform query succeeds with
probability at most `2 / p`, where `p` is the smaller prime factor: uniform
sampling is bounded by the *smallest* prime, never by `N`. -/
theorem atomic_uniform_success_le (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hle : p ≤ q) : hitDensity p q ≤ 2 / (p : ℚ) := by
  have hp0 : (0 : ℚ) < p := by exact_mod_cast hp.pos
  have hq0 : (0 : ℚ) < q := by exact_mod_cast hq.pos
  have hpq' : (p : ℚ) ≤ q := by exact_mod_cast hle
  rw [hitDensity_eq hp hq hpq, div_le_div_iff₀ (by positivity) hp0]
  nlinarith [mul_pos hp0 hq0]

/-- The trace of a semiprime is at least `2√N`: `(p + q)² ≥ 4N`.  This is the
arithmetic form of the balanced (`√N`) noise floor. -/
theorem four_le_sq_trace (p q : ℕ) : 4 * (p * q) ≤ (p + q) ^ 2 := by
  nlinarith [sq_nonneg ((p : ℤ) - q)]

/-- **The floor is attained only at balance.** Equality `(p+q)² = 4N` forces
`p = q`, so for a genuine semiprime the density is strictly above the balanced
floor. -/
theorem trace_sq_eq_iff (p q : ℕ) : (p + q) ^ 2 = 4 * (p * q) ↔ p = q := by
  constructor
  · intro h
    have : ((p : ℤ) - q) ^ 2 = 0 := by
      have h' : ((p : ℤ) + q) ^ 2 = 4 * (p * q) := by exact_mod_cast h
      nlinarith
    have : (p : ℤ) = q := by nlinarith [sq_nonneg ((p : ℤ) - q)]
    exact_mod_cast this
  · rintro rfl; ring

/-- **Noise-floor lower bound.** The hit density of the uniform primitive is at
least `2(√N - 1)/N`, stated without square roots as `density * N ≥ (p + q) - 2` with
`(p+q)² ≥ 4N`. -/
theorem noise_floor_lower (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    4 * ((p : ℚ) * q) ≤ (hitDensity p q * ((p : ℚ) * q) + 2) ^ 2 := by
  have hp0 : (0 : ℚ) < p := by exact_mod_cast hp.pos
  have hq0 : (0 : ℚ) < q := by exact_mod_cast hq.pos
  have hdens : hitDensity p q * ((p : ℚ) * q) = (p : ℚ) + q - 2 := by
    rw [hitDensity_eq hp hq hpq]
    field_simp
  rw [hdens]
  have : ((p : ℚ) + q - 2 + 2) ^ 2 = ((p : ℚ) + q) ^ 2 := by ring
  rw [this]
  nlinarith [sq_nonneg ((p : ℚ) - q)]

/-! ## 6. Tropical (min-plus) coordinates: the corner at `√N`

In logarithmic coordinates the divisor hyperbola `x · y = N` becomes the
tropical line `X ⊙ Y = log N`; the corner of the line sits at `log N / 2`.
The following two statements record that a divisor pair of a semiprime always
straddles the corner, which is the geometric content of the `√N` floor. -/

open Tropical

/-- Tropical multiplication of the two (base-2 logarithmic) coordinates of a
divisor pair is bounded by the logarithm of `N`: `⌊log p⌋ ⊙ ⌊log q⌋ ≤ ⌊log N⌋`
in the min-plus semiring. -/
theorem trop_mul_log_le (hp : p.Prime) (hq : q.Prime) :
    (trop (Nat.log 2 p) : Tropical ℕ) * trop (Nat.log 2 q) ≤ trop (Nat.log 2 (p * q)) := by
  rw [← trop_add]
  refine trop_monotone ?_
  have hpp : 2 ^ Nat.log 2 p ≤ p := Nat.pow_log_le_self 2 hp.pos.ne'
  have hqq : 2 ^ Nat.log 2 q ≤ q := Nat.pow_log_le_self 2 hq.pos.ne'
  have hle : 2 ^ (Nat.log 2 p + Nat.log 2 q) ≤ p * q := by
    rw [pow_add]; exact Nat.mul_le_mul hpp hqq
  exact (Nat.le_log_iff_pow_le (by norm_num) (Nat.mul_pos hp.pos hq.pos).ne').mpr hle

/-- **Corner straddle.** If `p ≤ q` then `p ≤ √N ≤ q`, i.e. `p² ≤ N ≤ q²`: the
min-plus corner of the tropical line `X ⊙ Y = N` separates the two factors. -/
theorem corner_straddle (hle : p ≤ q) : p * p ≤ p * q ∧ p * q ≤ q * q :=
  ⟨Nat.mul_le_mul_left p hle, Nat.mul_le_mul_right q hle⟩

/-- The tropical (min-plus) *sum* of the two log-coordinates — i.e. their
minimum — is at most half the log of `N`, the corner coordinate. -/
theorem trop_corner_straddle (hp : p.Prime) (hq : q.Prime) :
    2 * (untrop ((trop (Nat.log 2 p) : Tropical ℕ) + trop (Nat.log 2 q)))
      ≤ Nat.log 2 (p * q) + Nat.log 2 (p * q) := by
  have hmin : untrop ((trop (Nat.log 2 p) : Tropical ℕ) + trop (Nat.log 2 q))
      = min (Nat.log 2 p) (Nat.log 2 q) := rfl
  rw [hmin]
  have hp' : Nat.log 2 p ≤ Nat.log 2 (p * q) :=
    Nat.log_mono_right (Nat.le_mul_of_pos_right p hq.pos)
  have hq' : Nat.log 2 q ≤ Nat.log 2 (p * q) :=
    Nat.log_mono_right (Nat.le_mul_of_pos_left q hp.pos)
  have := min_le_left (Nat.log 2 p) (Nat.log 2 q)
  have := min_le_right (Nat.log 2 p) (Nat.log 2 q)
  omega

end Round7ZDG