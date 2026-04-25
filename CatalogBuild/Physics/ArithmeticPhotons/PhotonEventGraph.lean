/-! # CatalogBuild.Physics.ArithmeticPhotons.PhotonEventGraph

Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 21
-/

import Mathlib

noncomputable section

/-- Two events are null-separated (connected by a light ray) -/
def nullSeparated (e₁ e₂ : SpacetimeEvent) : Prop :=
  minkowskiInterval e₁ e₂ = 0


/-- An event e₂ is in the causal future of e₁ -/
def causalFuture (e₁ e₂ : SpacetimeEvent) : Prop :=
  e₁.t < e₂.t ∧ minkowskiInterval e₁ e₂ ≤ 0


/-- A photon edge: a worldline connecting an emission event to an absorption event.
The photon travels on a null geodesic (light ray). -/
structure PhotonEdge where
  emission : SpacetimeEvent   -- where the photon was created
  absorption : SpacetimeEvent -- where the photon was destroyed
  is_null : nullSeparated emission absorption  -- travels at speed of light
  time_ordered : emission.t < absorption.t     -- absorption is in the future


/-- The momentum of a photon edge (spatial displacement). -/
def PhotonEdge.momentum (p : PhotonEdge) : ℤ × ℤ :=
  (p.absorption.x - p.emission.x, p.absorption.y - p.emission.y)


/-- The energy of a photon edge (time displacement). -/
def PhotonEdge.energy (p : PhotonEdge) : ℤ :=
  p.absorption.t - p.emission.t


/-- Photon energy is always positive (time flows forward). -/
theorem PhotonEdge.energy_pos (p : PhotonEdge) : 0 < p.energy := by
  simp only [PhotonEdge.energy]
  linarith [p.time_ordered]


/-- The photon momentum and energy satisfy the on-shell condition:
px² + py² = E². This is the massless dispersion relation. -/
theorem PhotonEdge.on_shell (p : PhotonEdge) :
    (p.momentum.1)^2 + (p.momentum.2)^2 = p.energy^2 := by
  have h := p.is_null
  rw [null_iff_pythagorean] at h
  exact h


/-- A photon event graph: a collection of spacetime events connected by photon worldlines.
This models the complete history of photon emissions and absorptions. -/
structure PhotonEventGraph where
  /-- The set of all events (emission and absorption points) -/
  events : Finset SpacetimeEvent
  /-- The photon worldlines connecting events -/
  photons : Finset PhotonEdge
  /-- All photon endpoints are in the event set -/
  emission_mem : ∀ p ∈ photons, p.emission ∈ events
  absorption_mem : ∀ p ∈ photons, p.absorption ∈ events


/-- The number of photons in the graph -/
def PhotonEventGraph.photonCount (G : PhotonEventGraph) : ℕ := G.photons.card


/-- The number of events in the graph -/
def PhotonEventGraph.eventCount (G : PhotonEventGraph) : ℕ := G.events.card


/-- An event is an emitter if some photon originates from it -/
def PhotonEventGraph.isEmitter (G : PhotonEventGraph) (e : SpacetimeEvent) : Prop :=
  ∃ p ∈ G.photons, p.emission = e


/-- An event is an absorber if some photon terminates at it -/
def PhotonEventGraph.isAbsorber (G : PhotonEventGraph) (e : SpacetimeEvent) : Prop :=
  ∃ p ∈ G.photons, p.absorption = e


/-- The causal order on events: e₁ ≤ e₂ if there is a directed path of
photon worldlines from e₁ to e₂. -/
inductive PhotonEventGraph.causallyConnected (G : PhotonEventGraph) :
    SpacetimeEvent → SpacetimeEvent → Prop where
  | refl (e : SpacetimeEvent) : G.causallyConnected e e
  | step (e₁ e₂ e₃ : SpacetimeEvent) :
      (∃ p ∈ G.photons, p.emission = e₁ ∧ p.absorption = e₂) →
      G.causallyConnected e₂ e₃ →
      G.causallyConnected e₁ e₃


/-- Causal connectivity is transitive -/
theorem PhotonEventGraph.causallyConnected_trans (G : PhotonEventGraph)
    (e₁ e₂ e₃ : SpacetimeEvent)
    (h₁₂ : G.causallyConnected e₁ e₂) (h₂₃ : G.causallyConnected e₂ e₃) :
    G.causallyConnected e₁ e₃ := by
  induction h₁₂ with
  | refl _ => exact h₂₃
  | step a b c hstep _ ih => exact .step a b e₃ hstep (ih h₂₃)


/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonEventGraph
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 21] -/
theorem PhotonEventGraph.time_monotone (G : PhotonEventGraph)
    (e₁ e₂ : SpacetimeEvent)
    (hconn : G.causallyConnected e₁ e₂)
    (hne : e₁ ≠ e₂) : e₁.t < e₂.t := by
  revert hconn;
  -- We proceed by induction on the causal connectivity relation.
  intro h
  induction' h with e₁ e₂ h₁₂ h₂₃ h_ind;
  · contradiction;
  · obtain ⟨ p, hp, rfl, rfl ⟩ := h_ind;
    cases eq_or_ne p.absorption h₂₃ <;> simp_all +decide [ PhotonEdge.time_ordered ];
    · exact ‹p.absorption = h₂₃› ▸ p.time_ordered;
    · linarith [ p.time_ordered ]


/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonEventGraph
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 21] -/
theorem PhotonEventGraph.no_causal_loop (G : PhotonEventGraph)
    (e : SpacetimeEvent)
    (p : PhotonEdge) (hp : p ∈ G.photons) (hem : p.emission = e) :
    ¬ G.causallyConnected p.absorption e := by
  intro h;
  -- By the time monotonicity theorem, if $p.absorption$ is causally connected to $e$, then $p.absorption.t < e.t$.
  have h_time : p.absorption.t < e.t := by
    apply PhotonEventGraph.time_monotone G p.absorption e h;
    exact fun h' => by have := p.time_ordered; aesop;
  linarith [ p.time_ordered, show p.emission.t = e.t from congr_arg SpacetimeEvent.t hem ]


/-- The emission degree of an event (number of photons emitted from it). -/
noncomputable def PhotonEventGraph.emissionDegree (G : PhotonEventGraph) (e : SpacetimeEvent) : ℕ :=
  (G.photons.filter (fun p => p.emission = e)).card


/-- The absorption degree of an event (number of photons absorbed at it). -/
noncomputable def PhotonEventGraph.absorptionDegree (G : PhotonEventGraph) (e : SpacetimeEvent) : ℕ :=
  (G.photons.filter (fun p => p.absorption = e)).card


/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonEventGraph
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 21] -/
theorem PhotonEventGraph.total_emission_count (G : PhotonEventGraph) :
    G.photons.card = ∑ e ∈ G.events, G.emissionDegree e := by
  unfold PhotonEventGraph.emissionDegree;
  simp +decide only [card_filter];
  rw [ ← Finset.sum_comm ];
  simp +contextual [ G.emission_mem ]


/-- An entangled pair: two photons emitted from the same event with
opposite momenta (momentum conservation). -/
structure EntangledPair where
  photon1 : PhotonEdge
  photon2 : PhotonEdge
  same_source : photon1.emission = photon2.emission
  momentum_conservation :
    photon1.momentum.1 + photon2.momentum.1 = 0 ∧
    photon1.momentum.2 + photon2.momentum.2 = 0


theorem EntangledPair.equal_energy (ep : EntangledPair) :
    ep.photon1.energy = ep.photon2.energy := by
  -- By the on-shell condition, we have that for both photons, their energy squared is equal to the sum of the squares of their momentum components.
  have h_on_shell : ep.photon1.energy^2 = ep.photon1.momentum.1^2 + ep.photon1.momentum.2^2 ∧ ep.photon2.energy^2 = ep.photon2.momentum.1^2 + ep.photon2.momentum.2^2 := by
    exact ⟨ by linarith [ PhotonEdge.on_shell ep.photon1 ], by linarith [ PhotonEdge.on_shell ep.photon2 ] ⟩;
  -- By the momentum conservation condition, we have that the sum of the momentum components of the two photons is zero.
  have h_momentum_conserved : ep.photon1.momentum.1 + ep.photon2.momentum.1 = 0 ∧ ep.photon1.momentum.2 + ep.photon2.momentum.2 = 0 := by
    exact ep.momentum_conservation;
  rw [ ← sq_eq_sq₀ ] <;> try linarith [ PhotonEdge.energy_pos ep.photon1, PhotonEdge.energy_pos ep.photon2 ];
  simp_all +decide [ add_eq_zero_iff_eq_neg ]


end
