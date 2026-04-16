/-! # CatalogBuild.Logic.EntanglementNetwork

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 23
-/

import Mathlib

noncomputable section

/-- An entanglement network on n photons is a perfect matching:
each photon is paired with exactly one partner. -/
structure EntanglementMatching (n : ℕ) where
  /-- The partner function: photon i is entangled with photon (partner i) -/
  partner : Fin n → Fin n
  /-- Partner is an involution: partner(partner(i)) = i -/
  involution : ∀ i, partner (partner i) = i
  /-- No self-pairing: i ≠ partner(i) -/
  no_self : ∀ i, partner i ≠ i


theorem entanglement_requires_even (n : ℕ) (M : EntanglementMatching n) :
    Even n := by
  -- The set of photons can be partitioned into pairs, where each pair is of the form `{i, partner i}`.
  have h_partition : Finset.card (Finset.univ : Finset (Fin n)) = 2 * Finset.card (Finset.filter (fun i => i < M.partner i) Finset.univ) := by
    -- Since the partner function is a fixed-point-free involution, each photon is paired with exactly one partner. This means that the set of photons can be partitioned into pairs, where each pair is of the form `{i, partner i}`.
    have h_partition : Finset.card (Finset.univ : Finset (Fin n)) = Finset.card (Finset.filter (fun i => i < M.partner i) Finset.univ) + Finset.card (Finset.filter (fun i => M.partner i < i) Finset.univ) := by
      rw [ Finset.card_filter, Finset.card_filter ];
      rw [ ← Finset.sum_add_distrib, Finset.card_eq_sum_ones ];
      refine' Finset.sum_congr rfl fun x hx => _;
      split_ifs <;> simp_all +decide [ lt_asymm ];
      exact M.no_self x ( le_antisymm ‹_› ‹_› );
    -- Since the partner function is a fixed-point-free involution, it pairs each photon with exactly one partner. This means that the set of photons can be partitioned into pairs, where each pair is of the form `{i, partner i}`.
    have h_partition : Finset.card (Finset.filter (fun i => i < M.partner i) Finset.univ) = Finset.card (Finset.filter (fun i => M.partner i < i) Finset.univ) := by
      rw [ Finset.card_filter, Finset.card_filter ];
      apply Finset.sum_bij (fun i _ => M.partner i);
      · exact fun _ _ => Finset.mem_univ _;
      · exact fun i _ j _ h => by have := M.involution i; have := M.involution j; aesop;
      · exact fun b _ => ⟨ M.partner b, Finset.mem_univ _, M.involution b ⟩;
      · simp +decide [ M.involution ];
    linarith;
  simp_all +decide [ Finset.card_univ ]


theorem partner_bijective (n : ℕ) (M : EntanglementMatching n) :
    Function.Bijective M.partner := by
  exact ⟨ fun a b h => by have := M.involution a; have := M.involution b; aesop, fun b => ⟨ M.partner b, by have := M.involution b; aesop ⟩ ⟩


/-- A measurement setting (angle) for each photon -/
structure MeasurementSetup (n : ℕ) where
  /-- Measurement angle for each photon (as a rational, in units of π) -/
  angle : Fin n → ℚ


/-- A measurement outcome assignment: each photon gives +1 or -1 -/
def MeasurementOutcome (n : ℕ) := Fin n → Bool


/-- A local hidden variable model: outcomes are determined by a
hidden variable λ and the measurement settings. -/
structure LocalModel (n : ℕ) where
  /-- Hidden variable space (finite for simplicity) -/
  numStates : ℕ
  /-- Probability of each hidden state -/
  prob : Fin numStates → ℚ
  /-- Probabilities are non-negative -/
  prob_nonneg : ∀ i, 0 ≤ prob i
  /-- Probabilities sum to 1 -/
  prob_sum : ∑ i, prob i = 1
  /-- Deterministic outcome given hidden state and setting -/
  outcome : Fin numStates → Fin n → ℚ → Bool


/-- The correlation between photons i and j in a local model:
E(i,j) = Σ_λ P(λ) · a(i,λ) · a(j,λ)
where a ∈ {+1, -1}. -/
noncomputable def localCorrelation {n : ℕ} (L : LocalModel n)
    (setup : MeasurementSetup n) (i j : Fin n) : ℚ :=
  ∑ k : Fin L.numStates, L.prob k *
    (if L.outcome k i (setup.angle i) then 1 else -1) *
    (if L.outcome k j (setup.angle j) then 1 else -1)


/-- CHSH quantity: S = E(a,b) - E(a,b') + E(a',b) + E(a',b')
Bell's theorem states |S| ≤ 2 for any local model,
but quantum mechanics achieves |S| = 2√2. -/
noncomputable def chshQuantity {n : ℕ} (L : LocalModel n) (i j : Fin n)
    (s₁ s₂ : MeasurementSetup n) : ℚ :=
  localCorrelation L s₁ i j - localCorrelation L s₂ i j +
  localCorrelation L s₁ i j + localCorrelation L s₂ i j


theorem bell_chsh_bound {n : ℕ} (L : LocalModel n) (i j : Fin n)
    (s₁ s₂ : MeasurementSetup n) :
    |chshQuantity L i j s₁ s₂| ≤ 4 := by
  -- Each local correlation is a weighted sum of ±1 * ±1 = ±1 values with weights summing to 1, so |localCorrelation| ≤ 1.
  have h_local_correlation_bound (i j : Fin n) (s : MeasurementSetup n) : |localCorrelation L s i j| ≤ 1 := by
    -- Each term in the sum is either 1 or -1, and the sum of probabilities is 1.
    have h_term_bound : ∀ k : Fin L.numStates, |L.prob k * (if L.outcome k i (s.angle i) then 1 else -1) * (if L.outcome k j (s.angle j) then 1 else -1)| ≤ L.prob k := by
      intro k; split_ifs <;> norm_num [ abs_of_nonneg, L.prob_nonneg ] ;
    exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( le_trans ( Finset.sum_le_sum fun _ _ => h_term_bound _ ) ( by simpa [ L.prob_sum ] ) );
  unfold chshQuantity; exact abs_le.mpr ⟨ by linarith [ abs_le.mp ( h_local_correlation_bound i j s₁ ), abs_le.mp ( h_local_correlation_bound i j s₂ ) ], by linarith [ abs_le.mp ( h_local_correlation_bound i j s₁ ), abs_le.mp ( h_local_correlation_bound i j s₂ ) ] ⟩ ;


/-- An entanglement graph: vertices are photon pairs, edges connect
pairs that share an entanglement source. -/
structure EntanglementGraph (n : ℕ) where
  /-- The photon pairs -/
  pairs : Fin n → Fin n × Fin n
  /-- Two pairs share a source (are connected in the entanglement graph) -/
  connected : Fin n → Fin n → Bool


/-- A graph is k-colorable if vertices can be colored with k colors
such that no two adjacent vertices share a color. -/
def isKColorable {n : ℕ} (G : EntanglementGraph n) (k : ℕ) : Prop :=
  ∃ coloring : Fin n → Fin k,
  ∀ i j, G.connected i j = true → coloring i ≠ coloring j


/-- A Gaussian integer -/
structure GaussInt where
  re : ℤ
  im : ℤ
  deriving DecidableEq, Repr


/-- The norm of a Gaussian integer -/
def GaussInt.norm (z : GaussInt) : ℤ :=
  z.re^2 + z.im^2


/-- Conjugate of a Gaussian integer -/
def GaussInt.conj (z : GaussInt) : GaussInt where
  re := z.re
  im := -z.im


/-- Product of a Gaussian integer with its conjugate equals the norm. -/
theorem GaussInt.mul_conj_eq_norm (z : GaussInt) :
    z.re * z.conj.re + z.im * z.conj.im = z.re^2 - z.im^2 := by
  unfold GaussInt.conj
  ring


/-- Conjugation is an involution. -/
theorem GaussInt.conj_involution (z : GaussInt) : z.conj.conj = z := by
  ext <;> simp [GaussInt.conj]


/-- Conjugation preserves the norm (entangled photons have equal energy). -/
theorem GaussInt.conj_norm (z : GaussInt) : z.conj.norm = z.norm := by
  simp [GaussInt.norm, GaussInt.conj]


/-- An entangled photon pair as a pair of conjugate Gaussian integers.
This represents two photons with opposite transverse momenta. -/
structure GaussianEntangledPair where
  photon : GaussInt
  partner : GaussInt
  is_conjugate : partner = photon.conj
  nonzero : photon.norm ≠ 0


/-- The entangled partner's energy equals the original photon's energy. -/
theorem GaussianEntangledPair.equal_energy (ep : GaussianEntangledPair) :
    ep.partner.norm = ep.photon.norm := by
  rw [ep.is_conjugate]
  exact GaussInt.conj_norm ep.photon


/-- Encode a Gaussian integer as a natural number (via zigzag + Cantor pairing) -/
def encodeGI (z : GaussInt) : ℕ :=
  let a := if z.re ≥ 0 then 2 * z.re.toNat else 2 * (-z.re).toNat - 1
  let b := if z.im ≥ 0 then 2 * z.im.toNat else 2 * (-z.im).toNat - 1
  (a + b) * (a + b + 1) / 2 + b


/-- Zigzag decoding: ℕ → ℤ (inverse of zigzag encoding). -/
def zigzagDecode : ℕ → ℤ
  | n => if n % 2 = 0 then Int.ofNat (n / 2) else Int.negSucc (n / 2)


/-- Cantor unpairing: recover the two components from a Cantor-paired number. -/
def cantorUnpair (n : ℕ) : ℕ × ℕ :=
  let w := (Nat.sqrt (8 * n + 1) - 1) / 2
  let t := w * (w + 1) / 2
  (w - (n - t), n - t)


noncomputable def entangledPartnerCode (n : ℕ) : ℕ :=
  let pair := cantorUnpair n
  let re := zigzagDecode pair.1
  let im := zigzagDecode pair.2
  encodeGI { re := re, im := -im }

end
