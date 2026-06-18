# Future Directions: Verified Compositional Music Intelligence

## Direction 1: Finite Automata Realization Theorem

**Goal**: Prove that finite transition systems (deterministic or nondeterministic finite automata) induce musical specifications, and that simulation/bisimulation between automata implies refinement between specifications.

**Theorem target**:
```
def automatonSpec (δ : σ → α → σ) (init : σ) (accept : Set σ) : MusicSpec α :=
  { w | ∃ s, List.foldl δ init w = s ∧ s ∈ accept }

theorem automaton_simulation_refines
    (sim : σ₁ → σ₂ → Prop)
    (hsim : ∀ s₁ s₂ a, sim s₁ s₂ → sim (δ₁ s₁ a) (δ₂ s₂ a))
    (hinit : sim init₁ init₂)
    (haccept : ∀ s₁ s₂, sim s₁ s₂ → s₁ ∈ accept₁ → s₂ ∈ accept₂) :
    refines (automatonSpec δ₁ init₁ accept₁) (automatonSpec δ₂ init₂ accept₂)
```

**Cross-domain impact**: Bridges formal language theory and automata to our musical specification framework. Enables verified reasoning about finite-state generative music systems (Markov chains, hidden Markov models) with guaranteed refinement properties.

**Proof strategy**: Define the language of an automaton as the set of accepted words, then show that simulation is a sufficient condition for language inclusion. The key lemma is that simulation is preserved by `foldl` induction over the input word.

**Hypothesis**: The simulation relation between automata composes with our style transport: if automaton A₁ simulates A₂ and style map f respects the simulation, then `mapSpec f (automatonSpec A₁) ⊆ automatonSpec A₂'` where A₂' is the transported automaton.

---

## Direction 2: Probabilistic Specifications and Stochastic Refinement

**Goal**: Extend specifications from sets to probability measures over phrases, and extend refinement from subset inclusion to stochastic dominance or total variation bounds.

**Theorem targets**:
```
def ProbMusicSpec (α : Type*) := List α → ℝ≥0∞

def stochastic_refines (P Q : ProbMusicSpec α) : Prop :=
  ∀ S : Set (List α), (∑' w ∈ S, P w) ≤ (∑' w ∈ S, Q w)

theorem stochastic_compose_mono
    (hP : stochastic_refines P₁ P₂) (hQ : stochastic_refines Q₁ Q₂) :
    stochastic_refines (prob_compose P₁ Q₁) (prob_compose P₂ Q₂)
```

**Cross-domain impact**: Connects to measure-theoretic probability and ergodic theory. Directly relevant to probabilistic generative music systems (variational autoencoders, diffusion models, autoregressive transformers). A stochastic monotonicity theorem would certify that a model trained on a refined distribution cannot produce outputs violating the broader distribution's constraints in a probabilistic sense.

**Proof strategy**: Define probabilistic composition as convolution of distributions over phrase concatenation. Use Fubini-Tonelli to decompose the integral. Stochastic dominance is preserved under convolution by monotone coupling arguments.

**Hypothesis**: The stochastic refinement preorder, when restricted to Dirac measures concentrated on sets, recovers the deterministic refinement preorder. This provides a consistent embedding.

---

## Direction 3: Galois Connections Between Musical Vocabularies

**Goal**: Formalize a full Galois connection between fine-grained and coarse-grained musical event alphabets, with both abstraction and concretization maps, and prove that the connection preserves compositional structure.

**Theorem targets**:
```
structure MusicGalois (α β : Type*) where
  abs : α → β
  conc : β → Set α
  sound : ∀ a, a ∈ conc (abs a)
  optimal : ∀ b, abs '' (conc b) ⊆ {b}

theorem galois_preserves_compose
    (G : MusicGalois α β) (S T : MusicSpec α) :
    mapSpec G.abs (compose S T) ⊆
    compose (mapSpec G.abs S) (mapSpec G.abs T)

theorem galois_concretization_antitone
    (G : MusicGalois α β) {S T : MusicSpec β}
    (h : refines S T) :
    refines (concSpec G S) (concSpec G T)
```

**Cross-domain impact**: Connects to abstract interpretation (Cousot & Cousot, 1977) — the cornerstone of static program analysis. A musical Galois connection would enable verified "zooming" between levels of musical description: from individual pitches to pitch classes, from exact rhythms to metrical positions, from detailed harmony to roman-numeral analysis. This is directly useful for multi-resolution music analysis and hierarchical generative systems.

**Proof strategy**: Use the Galois connection framework from order theory in Mathlib. The key difficulty is ensuring that the monoidal structure (composition) is compatible with the Galois insertion, which requires proving that abstraction distributes over concatenation up to the Galois closure.

**Hypothesis**: For partitional abstractions (where `conc` maps each abstract event to a disjoint set of concrete events), the Galois connection is a Galois insertion and the monoidal functor law holds exactly (not just as an inclusion).

---

## Direction 4: Hierarchical Composition via Operads

**Goal**: Extend flat concatenation to hierarchical (tree-structured) composition using operads or multicategories, modeling nested musical structure (motif → phrase → section → movement).

**Theorem targets**:
```
inductive MusicTree (α : Type*) where
  | leaf : α → MusicTree α
  | node : List (MusicTree α) → MusicTree α

def TreeSpec (α : Type*) := Set (MusicTree α)

def tree_compose (S : TreeSpec α) (children : List (TreeSpec α)) : TreeSpec α :=
  { t | ∃ root ∈ S, ∃ subs, (∀ i, subs.get i ∈ (children.get i)) ∧ t = graft root subs }

theorem tree_refines_compose_mono
    (hS : refines S₁ S₂) (hC : ∀ i, refines (C₁.get i) (C₂.get i)) :
    refines (tree_compose S₁ C₁) (tree_compose S₂ C₂)
```

**Cross-domain impact**: Connects to operad theory in applied category theory and to context-free grammars in formal language theory. Directly models the hierarchical structure of Western tonal music (Lerdahl & Jackendoff's Generative Theory of Tonal Music). Enables verified reasoning about recursive generative systems and grammar-based composition.

**Proof strategy**: Define an operad of musical tree specifications. Prove that the refinement preorder is compatible with the operad structure (equivariant composition). Use induction on tree depth for the monoidal functor law.

**Hypothesis**: The flat concatenation framework (this paper) embeds into the operadic framework as the sub-operad of linear trees (no branching). All theorems from this paper should lift to the operadic setting.

---

## Direction 5: Differentiable Encoders and Certified Latent Representations

**Goal**: Prove that if an encoder-decoder pair between a discrete musical specification and a continuous latent space satisfies certain fidelity conditions, then refinement in the discrete domain implies a corresponding ordering in the latent space.

**Theorem targets**:
```
def latent_faithful (enc : List α → ℝ^d) (dec : ℝ^d → Set (List α)) : Prop :=
  ∀ w, w ∈ dec (enc w)

theorem faithful_encoder_reflects_refinement
    (hfaith : latent_faithful enc dec)
    (hS : refines S T)
    (w : List α) (hw : w ∈ S) :
    enc w ∈ enc '' T

-- Stronger: latent ordering
def latent_refines (enc : List α → ℝ^d) (S T : MusicSpec α) : Prop :=
  enc '' S ⊆ enc '' T

theorem latent_refines_of_refines
    (hS : refines S T) :
    latent_refines enc S T
```

**Cross-domain impact**: Bridges the gap between discrete algebraic specifications and continuous latent representations used in deep generative models (VAEs, diffusion models). If an encoder is faithful, then the refinement lattice embeds into the latent space, enabling neural networks to learn constraint-preserving transformations by operating in latent space while maintaining the algebraic guarantees proved in our framework.

**Proof strategy**: The key insight is that `refines S T` (i.e., `S ⊆ T`) immediately implies `enc '' S ⊆ enc '' T` by monotonicity of image. The interesting theorem is the converse under injectivity of the encoder, and the behavior under approximate (non-injective) encoders with controlled distortion.

**Hypothesis**: For injective encoders, latent refinement is equivalent to discrete refinement. For ε-approximately injective encoders (Hausdorff distance between fibers bounded by ε), latent refinement implies discrete refinement up to an ε-neighborhood. This would provide a quantitative certificate for neural encoder quality.

---

## Cross-Cutting Themes

All five directions share a common structure: extending the verified compositional backbone (monoidal preorder + monotone transport) to richer settings. Each direction adds one dimension of expressiveness:

| Direction | Extension | From → To |
|-----------|-----------|-----------|
| 1 | Generation mechanism | Sets → Automata |
| 2 | Quantitative reasoning | Boolean → Probabilistic |
| 3 | Multi-resolution | Single scale → Galois tower |
| 4 | Structural depth | Flat → Hierarchical |
| 5 | Representation | Discrete → Continuous |

The ultimate goal is a **verified compositional music intelligence stack**: a formally certified pipeline from high-level compositional specifications through style transfer and abstraction to implementable generative systems, with mathematical guarantees at every layer.
