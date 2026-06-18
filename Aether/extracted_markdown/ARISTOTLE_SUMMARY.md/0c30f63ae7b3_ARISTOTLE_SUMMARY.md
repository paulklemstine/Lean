# Summary of changes for run adf3431d-ae48-428e-9e2a-02dc322a1bcf
## Completed: Parameterized Projection Families and Key Recovery

Created `Cryptography/ProjectionCrypto.lean` — a fully proven Lean 4 formalization of parameterized projection families as cryptographic primitives, with structural theorems connecting key recovery to algebraic and information-theoretic properties.

### Core Framework
- **`ParamFamily K X Y`**: Structure modeling families of maps indexed by secret keys
- **`consistentKeys`**, **`keyUnique`**, **`keyAmbiguous`**: Key recovery predicates
- **`keyUnique_iff_not_ambiguous`**: Key uniqueness ↔ ¬ key ambiguity (proved)
- **`consistentKeys_antitone`**: More observations ⊆ fewer consistent keys (proved)
- **`keyUnique_mono`**: Key uniqueness is preserved under additional observations (proved)

### Group Action Families (3 theorems + boundary)
- **`groupAction_consistent_pair_iff_stabilizer`** ⭐: Two group elements are both consistent with an observation iff their ratio lies in the stabilizer subgroup — the **Stabilizer–Ambiguity Correspondence**
- **`free_action_key_unique`**: Free group actions are 1-determined (single observation uniquely determines the key)
- **`faithful_action_full_obs_determines`**: Faithful actions are determined by full observation
- **`nonfree_action_ambiguous`**: Non-free actions admit key ambiguity (boundary case)

### Affine Projection Family (3 theorems + boundary + generalization)
- **`affine_two_obs_key_unique`** ⭐: Two observations with distinct inputs uniquely determine the affine key (a, b)
- **`affine_single_obs_key_ambiguous`** ⭐: A single observation is always ambiguous for affine maps
- **`affine_injective`**: Nonzero-slope affine maps are injective
- **`affine_coincident_inconsistent`**: Coincident inputs with different outputs yield empty consistency set
- **`poly_eval_uniqueness`**: Generalization to polynomial interpolation uniqueness (degree d → d+1 observations)

### Information-Theoretic Bounds (2 theorems)
- **`pigeonhole_key_collision`**: When |K| > |Y|, distinct keys with identical output exist
- **`finite_family_collision_implies_ambiguity`**: Finite families with |K| > |Y| are inherently key-ambiguous

### Stereographic Projection Instance (3 theorems)
- **`stereoNorth_periodic`**: 2π-periodicity of stereographic projection
- **`stereoFamily_pole_periodic`**: Pole-angle periodicity of the projection family
- **`stereoNorth_at_south`**: South pole maps to 0

**All 17 theorems fully proved** — zero `sorry`, clean build, standard axioms only (propext, Classical.choice, Quot.sound). Concrete examples provided for each main theorem. Five future directions stated in trailing comments.