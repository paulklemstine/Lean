/-! # CatalogBuild.EML.AIResearch.AutoMLTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 48
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.EML.AIResearch.AutoMLTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 28] -/
def stdSearchSpace (opsPerEdge numEdges : ℕ) : ℕ := opsPerEdge ^ numEdges



/-- [Section: # CatalogBuild.EML.AIResearch.AutoMLTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 48] -/
def emlSearchSpace (numEdges : ℕ) : ℕ := 4 ^ numEdges




theorem eml_smaller_search_space (ops edges : ℕ) (hops : 4 ≤ ops) :
    emlSearchSpace edges ≤ stdSearchSpace ops edges := by
  unfold emlSearchSpace stdSearchSpace; exact Nat.pow_le_pow_left hops edges




def stdEvalCost (archParams epochs batchCost : ℕ) : ℕ := archParams * epochs * batchCost



def emlEvalCost (emlParams epochs batchCost : ℕ) : ℕ := emlParams * epochs * batchCost




theorem eml_eval_faster (p_eml p_std e b : ℕ) (hp : p_eml ≤ p_std) :
    emlEvalCost p_eml e b ≤ stdEvalCost p_std e b := by
  unfold emlEvalCost stdEvalCost
  have : p_eml * e ≤ p_std * e := Nat.mul_le_mul_right e hp
  exact Nat.mul_le_mul_right b this




def supernetParams (numPaths pathWidth depth : ℕ) : ℕ := numPaths * depth * pathWidth * pathWidth



def emlSupernetParams (numPaths pathWidth depth : ℕ) : ℕ := numPaths * depth * 4 * pathWidth




theorem eml_supernet_smaller (n w d : ℕ) (hw : 4 ≤ w) :
    emlSupernetParams n w d ≤ supernetParams n w d := by
  unfold emlSupernetParams supernetParams
  have : n * d * 4 ≤ n * d * w := Nat.mul_le_mul_left (n * d) hw
  exact Nat.mul_le_mul_right w this




def hparamSensitivity (lipschitzConst perturbation : ℝ) : ℝ := lipschitzConst * perturbation




theorem smaller_lipschitz_less_sensitive (L1 L2 delta : ℝ) (hd : 0 ≤ delta) (hL : L1 ≤ L2) :
    hparamSensitivity L1 delta ≤ hparamSensitivity L2 delta := by
  unfold hparamSensitivity; exact mul_le_mul_of_nonneg_right hL hd




theorem zero_perturbation_stable (L : ℝ) : hparamSensitivity L 0 = 0 := by
  unfold hparamSensitivity; ring




def transferNASCost (sourceSearchCost targetFinetuneCost : ℕ) : ℕ :=
  sourceSearchCost + targetFinetuneCost



def emlTransferNASCost (sourceSearchCost emlFinetuneCost : ℕ) : ℕ :=
  sourceSearchCost + emlFinetuneCost




theorem eml_transfer_cheaper (s ft_eml ft_std : ℕ) (hft : ft_eml ≤ ft_std) :
    emlTransferNASCost s ft_eml ≤ transferNASCost s ft_std := by
  unfold emlTransferNASCost transferNASCost; omega




def zeroShotCost (numCandidates proxyCost : ℕ) : ℕ := numCandidates * proxyCost



def emlZeroShotCost (numCandidates emlProxyCost : ℕ) : ℕ := numCandidates * emlProxyCost




theorem eml_zero_shot_cheaper (n c_eml c_std : ℕ) (hc : c_eml ≤ c_std) :
    emlZeroShotCost n c_eml ≤ zeroShotCost n c_std := by
  unfold emlZeroShotCost zeroShotCost; exact Nat.mul_le_mul_left n hc




def paretoEfficiency (accuracy : ℝ) (params : ℕ) : ℝ := accuracy / ↑params




theorem eml_pareto_better (acc : ℝ) (p_eml p_std : ℕ) (hacc : 0 < acc)
    (hp_eml : 0 < p_eml) (hp : p_eml ≤ p_std) :
    paretoEfficiency acc p_std ≤ paretoEfficiency acc p_eml := by
  unfold paretoEfficiency
  exact div_le_div_of_nonneg_left (by linarith) (by positivity) (by exact_mod_cast hp)




def compoundScale (baseParams widthMult depthMult : ℕ) : ℕ :=
  baseParams * widthMult * widthMult * depthMult



def emlCompoundScale (baseParams widthMult depthMult : ℕ) : ℕ :=
  baseParams * widthMult * depthMult




theorem eml_scales_better (b w d : ℕ) (hw : 1 ≤ w) :
    emlCompoundScale b w d ≤ compoundScale b w d := by
  unfold emlCompoundScale compoundScale
  have : b * w ≤ b * w * w := Nat.le_mul_of_pos_right _ (by omega)
  exact Nat.mul_le_mul_right d this




def nasWithEarlyStopping (numCandidates avgEpochs costPerEpoch : ℕ) : ℕ :=
  numCandidates * avgEpochs * costPerEpoch




theorem eml_nas_early_stopping (n e_eml e_std c : ℕ) (he : e_eml ≤ e_std) :
    nasWithEarlyStopping n e_eml c ≤ nasWithEarlyStopping n e_std c := by
  unfold nasWithEarlyStopping
  have : n * e_eml ≤ n * e_std := Nat.mul_le_mul_left n he
  exact Nat.mul_le_mul_right c this




def stdWeightSharingParams (numOps dim : ℕ) : ℕ := numOps * dim * dim



def emlWeightSharingParams (numOps dim : ℕ) : ℕ := numOps * 4 * dim




theorem eml_weight_sharing_cheaper (ops d : ℕ) (hd : 4 ≤ d) :
    emlWeightSharingParams ops d ≤ stdWeightSharingParams ops d := by
  unfold emlWeightSharingParams stdWeightSharingParams
  have : ops * 4 ≤ ops * d := Nat.mul_le_mul_left ops hd
  exact Nat.mul_le_mul_right d this




/-- [Section: ## §1. Search Space Reduction] -/
theorem eml_search_smaller (nc nL ps : ℕ) (hp : 4 ≤ ps) :
    emlSearchSpace nc nL ≤ stdSearchSpace nc nL ps := by
  unfold emlSearchSpace stdSearchSpace
  exact Nat.mul_le_mul_left _ hp



/-- Supernet total parameters -/
def stdSupernetParams (numOps d_model d_ff numLayers : ℕ) : ℕ :=
  numLayers * numOps * (2 * d_model * d_ff)



theorem eml_supernet_compact (nO dm df nL : ℕ) (hd : 2 ≤ dm) :
    emlSupernetParams nO df nL ≤ stdSupernetParams nO dm df nL := by
  unfold emlSupernetParams stdSupernetParams
  gcongr; omega



/-- [Section: ## §2. Architecture Evaluation] -/
def evalCost (modelParams dataSize : ℕ) : ℕ := modelParams * dataSize



theorem eml_eval_cheaper (p_eml p_std ds : ℕ) (hp : p_eml ≤ p_std) :
    evalCost p_eml ds ≤ evalCost p_std ds := by
  unfold evalCost; exact Nat.mul_le_mul_right ds hp



def totalSearchCost (numCandidates evalCostPerCandidate : ℕ) : ℕ :=
  numCandidates * evalCostPerCandidate



theorem fewer_candidates_cheaper (n1 n2 ec : ℕ) (hn : n1 ≤ n2) :
    totalSearchCost n1 ec ≤ totalSearchCost n2 ec := by
  unfold totalSearchCost; exact Nat.mul_le_mul_right ec hn



/-- [Section: ## §3. Progressive Pruning] -/
def remainingAfterPrune (total keepFrac : ℕ) : ℕ := total * keepFrac / 100



/-- [Section: ## §4. Weight Sharing] -/
def emlSharedWeights (numPaths d_ff : ℕ) : ℕ := numPaths * (4 * d_ff)


def stdSharedWeights (numPaths d_model d_ff : ℕ) : ℕ := numPaths * (2 * d_model * d_ff)



theorem eml_sharing_compact (np dm df : ℕ) (hd : 2 ≤ dm) :
    emlSharedWeights np df ≤ stdSharedWeights np dm df := by
  unfold emlSharedWeights stdSharedWeights
  gcongr; omega



/-- [Section: ## §5. Architecture Encoding] -/
def emlArchEncoding (numLayers : ℕ) : ℕ := 2 * numLayers


def stdArchEncoding (numLayers opsPerLayer : ℕ) : ℕ := 3 * numLayers * opsPerLayer



theorem eml_encoding_compact (nL nO : ℕ) (ho : 1 ≤ nO) :
    emlArchEncoding nL ≤ stdArchEncoding nL nO := by
  unfold emlArchEncoding stdArchEncoding; nlinarith



/-- [Section: ## §6. Multi-Objective Search] -/
def paretoDominates (acc_a cost_a acc_b cost_b : ℝ) : Prop :=
  acc_a ≥ acc_b ∧ cost_a ≤ cost_b ∧ (acc_a > acc_b ∨ cost_a < cost_b)



theorem lower_cost_pareto_viable (acc cost_a cost_b : ℝ) (hc : cost_a < cost_b) :
    ¬paretoDominates acc cost_b acc cost_a := by
  unfold paretoDominates; intro ⟨_, h2, _⟩; linarith



/-- [Section: ## §7. Hardware-Aware NAS] -/
def inferenceLatency (modelParams throughput : ℕ) : ℕ := modelParams / throughput



theorem eml_faster_inference (p_eml p_std tp : ℕ) (hp : p_eml ≤ p_std) :
    inferenceLatency p_eml tp ≤ inferenceLatency p_std tp := by
  unfold inferenceLatency; exact Nat.div_le_div_right hp



/-- [Section: ## §8. Evolutionary NAS Population] -/
def populationMemory (popSize archWeights : ℕ) : ℕ := popSize * archWeights



theorem eml_pop_memory_smaller (ps w_eml w_std : ℕ) (hw : w_eml ≤ w_std) :
    populationMemory ps w_eml ≤ populationMemory ps w_std := by
  unfold populationMemory; exact Nat.mul_le_mul_left ps hw



end
