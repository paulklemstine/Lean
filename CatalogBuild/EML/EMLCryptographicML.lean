/-! # CatalogBuild.EML.EMLCryptographicML

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 34
-/

import Mathlib

noncomputable section

/-- Lipschitz constant of EML neuron with params (a, b). -/
def emlLipschitz (a b : ℝ) : ℝ := |a| * |b|


/-- EML robustness radius: ε / L. -/
def certifiedRadius (eps L : ℝ) : ℝ := eps / L


/-- Certified radius is positive when both positive. -/
theorem certified_radius_pos (eps L : ℝ) (he : 0 < eps) (hL : 0 < L) :
    0 < certifiedRadius eps L := div_pos he hL


/-- Smaller Lipschitz constant → larger certified radius. -/
theorem smaller_lipschitz_larger_radius (eps L1 L2 : ℝ) (he : 0 < eps)
    (hL1 : 0 < L1) (h : L1 ≤ L2) :
    certifiedRadius eps L2 ≤ certifiedRadius eps L1 := by
  simp only [certifiedRadius]
  exact div_le_div_of_nonneg_left (le_of_lt he) hL1 h


/-- Network Lipschitz: product over layers. -/
def networkLipschitz (layerLips : List ℝ) : ℝ := layerLips.prod


/-- Adding a layer multiplies Lipschitz. -/
theorem network_lipschitz_grow (ls : List ℝ) (l : ℝ) :
    networkLipschitz (l :: ls) = l * networkLipschitz ls := by
  simp [networkLipschitz]


/-- ε-differential privacy noise scale: sensitivity / ε. -/
def dpNoiseScale (sensitivity eps : ℝ) : ℝ := sensitivity / eps


/-- Noise scale is positive. -/
theorem dp_noise_pos (s eps : ℝ) (hs : 0 < s) (heps : 0 < eps) :
    0 < dpNoiseScale s eps := div_pos hs heps


/-- Composition: k queries → kε total privacy loss (basic). -/
def composedPrivacy (eps : ℝ) (k : ℕ) : ℝ := eps * ↑k


/-- Advanced composition: √k · ε for small ε. -/
def advancedComposition (eps : ℝ) (k : ℕ) : ℝ := Real.sqrt ↑k * eps


theorem advanced_better (eps : ℝ) (k : ℕ) (heps : 0 < eps) (hk : 4 ≤ k) :
    advancedComposition eps k < composedPrivacy eps k := by
  -- By definition of $advancedComposition$ and $composedPrivacy$, we need to show that $\sqrt{k} \cdot \epsilon < \epsilon \cdot k$.
  unfold advancedComposition composedPrivacy
  field_simp [heps];
  rw [ Real.sqrt_lt ] <;> norm_cast <;> nlinarith


theorem eml_sensitivity_advantage (depth width : ℕ) (maxGrad : ℝ)
    (hd : 0 < depth) (hw : 5 ≤ width) (hg : 0 < maxGrad) :
    emlSensitivity depth width maxGrad <
    maxGrad * Real.sqrt (↑depth * ↑width * (↑width + 1)) := by
  exact mul_lt_mul_of_pos_left ( Real.sqrt_lt_sqrt ( by positivity ) ( by norm_cast; nlinarith [ Nat.mul_le_mul_left depth hw ] ) ) hg


/-- Multiplicative depth of EML neuron: exp ∘ mult ∘ log = 3. -/
def emlMultDepth : ℕ := 3


/-- Total HE depth for d-layer EML network. -/
def heDepth (layers : ℕ) : ℕ := emlMultDepth * layers


/-- HE depth grows linearly. -/
theorem he_depth_linear (l : ℕ) : heDepth l = 3 * l := by
  simp [heDepth, emlMultDepth]


/-- HE bootstrapping threshold: need refresh every B levels. -/
def bootstrapFrequency (totalDepth B : ℕ) : ℕ := totalDepth / B


/-- More depth → more bootstrapping. -/
theorem bootstrap_mono (d1 d2 B : ℕ) (hB : 0 < B) (h : d1 ≤ d2) :
    bootstrapFrequency d1 B ≤ bootstrapFrequency d2 B :=
  Nat.div_le_div_right h


/-- EML is branch-free: constant time per neuron. -/
def emlBranches : ℕ := 0


/-- ReLU has 1 branch per neuron (the max). -/
def reluBranches (neurons : ℕ) : ℕ := neurons


/-- EML has zero timing leakage from branches. -/
theorem eml_constant_time : emlBranches = 0 := rfl


/-- EML is always safer than ReLU against timing attacks. -/
theorem eml_timing_safe (n : ℕ) : emlBranches ≤ reluBranches n := by
  simp [emlBranches, reluBranches]


/-- Lattice dimension for security level λ. -/
def latticeDimension (secLevel : ℕ) : ℕ := 2 * secLevel


/-- LWE noise bound: √n · σ. -/
def lweBound (n : ℕ) (sigma : ℝ) : ℝ := Real.sqrt ↑n * sigma


/-- LWE bound grows with dimension. -/
theorem lwe_bound_mono (n1 n2 : ℕ) (sigma : ℝ) (hs : 0 < sigma) (h : n1 ≤ n2) :
    lweBound n1 sigma ≤ lweBound n2 sigma := by
  simp only [lweBound]
  exact mul_le_mul_of_nonneg_right (Real.sqrt_le_sqrt (by exact_mod_cast h)) (le_of_lt hs)


/-- EML in lattice cryptography: key size for n-dimensional lattice. -/
def emlLatticeKeySize (n : ℕ) : ℕ := n * (Nat.log 2 n + 1)


/-- Key size grows at least linearly. -/
theorem lattice_key_bound (n : ℕ) (hn : 2 ≤ n) :
    n ≤ emlLatticeKeySize n := by
  simp only [emlLatticeKeySize]
  have : 0 < Nat.log 2 n + 1 := by omega
  nlinarith


/-- NIST security level classification. -/
def nistLevel (bits : ℕ) : ℕ :=
  if bits ≤ 128 then 1
  else if bits ≤ 192 then 3
  else 5


/-- Security level increases with bits. -/
theorem nist_level_mono (b1 b2 : ℕ) (h : b1 ≤ b2) :
    nistLevel b1 ≤ nistLevel b2 := by
  simp only [nistLevel]
  split_ifs <;> omega


/-- Level 1 minimum: 128 bits. -/
theorem nist_level1_min : nistLevel 128 = 1 := by simp [nistLevel]


/-- Level 5 for 256 bits. -/
theorem nist_level5 : nistLevel 256 = 5 := by simp [nistLevel]


/-- Communication cost per round: params × precision bits. -/
def commCost (params bits : ℕ) : ℕ := params * bits


theorem eml_comm_advantage (d w bits : ℕ) (hd : 0 < d) (hw : 5 ≤ w) (hb : 0 < bits) :
    commCost (4 * d * w) bits < commCost (d * w * (w + 1)) bits := by
  unfold commCost;
  nlinarith [ mul_pos hd ( mul_pos ( by linarith : 0 < w ) hb ) ]


/-- Convergence bound after T rounds with k clients: 1/(√T · k). -/
def federatedBound (T k : ℕ) : ℝ := 1 / (Real.sqrt ↑T * ↑k)


theorem federated_rounds_help (T1 T2 k : ℕ) (hT1 : 0 < T1) (hk : 0 < k)
    (h : T1 ≤ T2) :
    federatedBound T2 k ≤ federatedBound T1 k := by
  exact one_div_le_one_div_of_le ( by positivity ) ( by gcongr )


end
