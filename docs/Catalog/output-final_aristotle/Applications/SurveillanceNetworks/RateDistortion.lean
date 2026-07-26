/-
# Information-theoretic limits of surveillance on finite dynamic networks

We model an observer watching a dynamic social network whose instantaneous
configuration ranges over a finite state space `S` (for example, the set of all
adjacency relations the network may exhibit at a given instant).  The observer
records a measurement drawn from an alphabet `M` through an *observation channel*
`obs : S → M`, and later attempts to reconstruct the true configuration with a
*decoder* `dec : M → S`.

Two idealized regimes are of interest:

* **Perfect surveillance** — the channel is injective, so the true configuration
  is always recoverable from the record.
* **Perfect privacy** — the channel is constant, so the record reveals nothing
  about the configuration.

The central results below quantify the privacy–utility tradeoff as a
rate–distortion problem:

* A faithful reconstruction forces the observation alphabet to be at least as
  large as the state space, hence the observer must collect at least
  `log₂ |S|` bits (`recon_bits`).
* Under a distortion budget `D` measured by a dissimilarity `d`, the number of
  distinct measurements the observer must emit — the *rate* — is at least
  `|S| / B`, where `B` bounds the size of any distortion ball
  (`covering_rate_bound`).
* Perfect privacy pins the rate to `1` (`rate_eq_one_of_privacy`); combined with
  the covering bound, a private observer can meet a distortion budget only if a
  single ball already covers the whole network (`privacy_forces_ball_cover`).
* For any non-trivial network (at least two configurations) perfect privacy and
  faithful reconstruction are mutually exclusive (`privacy_no_recon`), and so are
  perfect privacy and perfect surveillance (`privacy_surv_exclusive`).

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  On a finite dynamic network the observer's minimum
collected information and the achievable reconstruction fidelity obey a hard
rate–distortion tradeoff, and the two extreme regimes — perfect privacy and
perfect surveillance — cannot coexist once the network has more than one state.

EXPERIMENT (Experimenter).  Model configurations as a finite type `S`,
observations as `obs : S → M`, reconstruction as `dec : M → S`.  Perfect
reconstruction `dec ∘ obs = id` forces `obs` injective, giving the counting
bound `|S| ≤ |M|` and hence `log₂ |S| ≤ log₂ |M|` bits.  For the distortion
version, partition `S` by the observation fibres: every configuration mapped to a
symbol `m` lies in the distortion ball around `dec m`, so each fibre is bounded by
the ball size `B`, and summing over the used symbols gives `|S| ≤ rate · B`.

ANALYSIS (Analyst).  The fibrewise covering argument is the structural heart: it
converts a channel/decoder pair into a covering of the state space by distortion
balls indexed by the emitted symbols.  Perfect privacy is exactly the degenerate
covering by a single ball, which recovers the impossibility results as the
`rate = 1` corner of the same inequality.

CRITIQUE (Critic).  The impossibility statements are vacuous unless the network
is non-trivial, so every such theorem carries the hypothesis `2 ≤ |S|`, and
`Fintype.exists_pair_of_one_lt_card` supplies the witnessing distinct
configurations.  The existence half `exists_surveillance_iff` shows the counting
bound is tight, ruling out a trivial reading.  No result collapses to `True` or a
pure `decide`.

SYNTHESIS (PI).  A single covering inequality unifies the bit lower bound, the
rate–distortion lower bound, and the privacy/surveillance impossibility, with the
private regime sitting at its `rate = 1` boundary.
-/
import Mathlib

open Function Finset

namespace SurveillanceNetworks

variable {S M : Type*} [Fintype S] [Fintype M] [DecidableEq S] [DecidableEq M]

-- An observation channel is a map `obs : S → M`; a decoder is a map `dec : M → S`.

/-- `dec` reconstructs every configuration faithfully from its record. -/
def PerfectReconstruction (obs : S → M) (dec : M → S) : Prop := ∀ s, dec (obs s) = s

/-- The channel reveals nothing: every configuration yields the same record. -/
def PerfectPrivacy (obs : S → M) : Prop := ∀ s t, obs s = obs t

/-- The channel is injective: distinct configurations are always distinguishable. -/
def PerfectSurveillance (obs : S → M) : Prop := Function.Injective obs

/-- The **rate** of a channel: the number of distinct records it can emit. -/
def rate (obs : S → M) : ℕ := (Finset.univ.image obs).card

/-! ### Perfect reconstruction: the fundamental counting bound -/

omit [Fintype S] [Fintype M] [DecidableEq S] [DecidableEq M] in
/-- Faithful reconstruction forces the observation channel to be injective. -/
theorem recon_inj {obs : S → M} {dec : M → S} (h : PerfectReconstruction obs dec) :
    Function.Injective obs := by
  intro s t hst
  have := h s
  rw [hst, h t] at this
  exact this.symm

omit [DecidableEq S] [DecidableEq M] in
/-- To reconstruct the network exactly, the observer's alphabet must be at least
as large as the state space. -/
theorem recon_card_le {obs : S → M} {dec : M → S} (h : PerfectReconstruction obs dec) :
    Fintype.card S ≤ Fintype.card M :=
  Fintype.card_le_of_injective obs (recon_inj h)

omit [DecidableEq S] [DecidableEq M] in
/-- **Minimum information for perfect surveillance.**  Exact reconstruction of a
finite network requires the observer to collect at least `log₂ |S|` bits. -/
theorem recon_bits {obs : S → M} {dec : M → S} (h : PerfectReconstruction obs dec) :
    Nat.log 2 (Fintype.card S) ≤ Nat.log 2 (Fintype.card M) :=
  Nat.log_mono_right (recon_card_le h)

omit [DecidableEq S] [DecidableEq M] in
/-- Perfect surveillance is achievable exactly when the record alphabet is at
least as large as the state space; the counting bound is therefore tight. -/
theorem exists_surveillance_iff :
    (∃ obs : S → M, PerfectSurveillance obs) ↔ Fintype.card S ≤ Fintype.card M := by
  constructor
  · rintro ⟨obs, hobs⟩
    exact Fintype.card_le_of_injective obs hobs
  · intro h
    obtain ⟨e⟩ := Function.Embedding.nonempty_of_card_le h
    exact ⟨e, e.injective⟩

omit [Fintype S] [Fintype M] [DecidableEq S] [DecidableEq M] in
/-- Perfect privacy is always available whenever the record alphabet is nonempty. -/
theorem exists_privacy [Nonempty M] : ∃ obs : S → M, PerfectPrivacy obs :=
  ⟨fun _ => Classical.arbitrary M, fun _ _ => rfl⟩

/-! ### The rate–distortion covering bound -/

omit [Fintype M] [DecidableEq S] in
/-- **Rate–distortion lower bound.**  Fix a dissimilarity `d` on configurations, a
distortion budget `D`, and a bound `B` on the size of every distortion ball
`{s | d c s ≤ D}`.  If the observer reconstructs every configuration to within
`D`, then the channel must emit at least `|S| / B` distinct records:
`|S| ≤ rate · B`. -/
theorem covering_rate_bound (obs : S → M) (dec : M → S) (d : S → S → ℕ) (D B : ℕ)
    (hball : ∀ c : S, (Finset.univ.filter (fun s => d c s ≤ D)).card ≤ B)
    (hrec : ∀ s, d (dec (obs s)) s ≤ D) :
    Fintype.card S ≤ rate obs * B := by
  have hpart : (Finset.univ : Finset S).card
      = ∑ m ∈ Finset.univ.image obs, (Finset.univ.filter (fun s => obs s = m)).card := by
    apply Finset.card_eq_sum_card_fiberwise
    intro x _
    exact Finset.mem_image_of_mem obs (Finset.mem_univ x)
  rw [Fintype.card, hpart, rate]
  calc ∑ m ∈ Finset.univ.image obs, (Finset.univ.filter (fun s => obs s = m)).card
      ≤ ∑ _m ∈ Finset.univ.image obs, B := by
        apply Finset.sum_le_sum
        intro m _
        refine le_trans (Finset.card_le_card ?_) (hball (dec m))
        intro s hs
        simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hs ⊢
        rw [← hs]
        exact hrec s
    _ = (Finset.univ.image obs).card * B := by rw [Finset.sum_const]; ring

/-! ### Perfect privacy: the `rate = 1` corner and its impossibilities -/

omit [Fintype M] [DecidableEq S] in
/-- A perfectly private channel has rate exactly `1`: it emits a single record. -/
theorem rate_eq_one_of_privacy [Nonempty S] {obs : S → M} (hp : PerfectPrivacy obs) :
    rate obs = 1 := by
  rw [rate, Finset.card_eq_one]
  refine ⟨obs (Classical.arbitrary S), ?_⟩
  apply Finset.eq_singleton_iff_unique_mem.2
  refine ⟨Finset.mem_image_of_mem obs (Finset.mem_univ _), ?_⟩
  intro x hx
  simp only [Finset.mem_image, Finset.mem_univ, true_and] at hx
  obtain ⟨a, ha⟩ := hx
  rw [← ha]
  exact hp a _

omit [Fintype M] [DecidableEq S] in
/-- **Privacy versus distortion.**  A perfectly private observer can meet the
distortion budget `D` only if a single distortion ball already covers the entire
network: `|S| ≤ B`.  Thus privacy is compatible with fidelity only when the
network is intrinsically indistinguishable at scale `D`. -/
theorem privacy_forces_ball_cover [Nonempty S] (obs : S → M) (dec : M → S)
    (d : S → S → ℕ) (D B : ℕ)
    (hball : ∀ c : S, (Finset.univ.filter (fun s => d c s ≤ D)).card ≤ B)
    (hp : PerfectPrivacy obs) (hrec : ∀ s, d (dec (obs s)) s ≤ D) :
    Fintype.card S ≤ B := by
  have h := covering_rate_bound obs dec d D B hball hrec
  rw [rate_eq_one_of_privacy hp, one_mul] at h
  exact h

omit [Fintype M] [DecidableEq S] [DecidableEq M] in
/-- **Perfect privacy forbids faithful reconstruction** of a non-trivial network:
if the network has at least two configurations, no decoder can recover a perfectly
private channel. -/
theorem privacy_no_recon {obs : S → M} {dec : M → S} (h2 : 2 ≤ Fintype.card S)
    (hp : PerfectPrivacy obs) : ¬ PerfectReconstruction obs dec := by
  intro hr
  have hinj := recon_inj hr
  obtain ⟨s, t, hst⟩ := Fintype.exists_pair_of_one_lt_card (α := S) (by omega)
  exact hst (hinj (hp s t))

omit [Fintype M] [DecidableEq S] [DecidableEq M] in
/-- **Perfect surveillance and perfect privacy are mutually exclusive** on any
finite network with at least two configurations. -/
theorem privacy_surv_exclusive {obs : S → M} (h2 : 2 ≤ Fintype.card S) :
    ¬ (PerfectPrivacy obs ∧ PerfectSurveillance obs) := by
  rintro ⟨hp, hs⟩
  obtain ⟨s, t, hst⟩ := Fintype.exists_pair_of_one_lt_card (α := S) (by omega)
  exact hst (hs (hp s t))

omit [Fintype M] [DecidableEq S] [DecidableEq M] in
/-- Contrapositive summary: on a non-trivial network a channel achieving perfect
surveillance necessarily leaks — it cannot be perfectly private. -/
theorem surv_leaks {obs : S → M} (h2 : 2 ≤ Fintype.card S)
    (hs : PerfectSurveillance obs) : ¬ PerfectPrivacy obs := by
  intro hp
  exact privacy_surv_exclusive h2 ⟨hp, hs⟩

/-! ### Concrete instantiation: directed social networks on `n` nodes

A snapshot of a directed social network on `n` participants is an adjacency
relation `Fin n → Fin n → Bool`.  There are exactly `2 ^ (n * n)` such snapshots,
so the abstract bounds above specialize to concrete bit counts. -/

/-- The number of directed network snapshots on `n` nodes is `2 ^ (n * n)`. -/
theorem card_directed_network (n : ℕ) :
    Fintype.card (Fin n → Fin n → Bool) = 2 ^ (n * n) := by
  simp [Fintype.card_bool, Fintype.card_fin]
  ring

/-- **Reconstructing a directed network costs `n²` bits.**  Any observer that can
exactly reconstruct every directed social network on `n` nodes must collect at
least `n * n` bits of information. -/
theorem directed_network_bits {M : Type*} [Fintype M] {n : ℕ}
    (obs : (Fin n → Fin n → Bool) → M) (dec : M → (Fin n → Fin n → Bool))
    (h : PerfectReconstruction obs dec) :
    n * n ≤ Nat.log 2 (Fintype.card M) := by
  have hb := recon_bits h
  rw [card_directed_network, Nat.log_pow (b := 2) (by norm_num)] at hb
  exact hb

/-- On any network with at least one node the snapshot space is non-trivial, so
perfect privacy and perfect surveillance cannot coexist there either. -/
theorem directed_network_privacy_surv_exclusive {M : Type*} [Fintype M] {n : ℕ}
    (hn : 1 ≤ n) (obs : (Fin n → Fin n → Bool) → M) :
    ¬ (PerfectPrivacy obs ∧ PerfectSurveillance obs) := by
  apply privacy_surv_exclusive
  rw [card_directed_network]
  have : 1 ≤ n * n := Nat.mul_pos hn hn
  calc 2 = 2 ^ 1 := by norm_num
    _ ≤ 2 ^ (n * n) := Nat.pow_le_pow_right (by norm_num) this

end SurveillanceNetworks