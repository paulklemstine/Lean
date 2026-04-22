import Mathlib

/-! # CatalogBuild.EML.AIResearch.MixtureOfDepthsTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 12
-/

noncomputable section

/-- Standard cost: all tokens processed through all layers -/
def stdFullCost (numTokens numLayers layerCost : ℕ) : ℕ :=
  numTokens * (numLayers * layerCost)

/-- MoD cost: each token may skip some layers -/
def modCost (numTokens avgActiveLayers layerCost : ℕ) : ℕ :=
  numTokens * (avgActiveLayers * layerCost)

/-- [Section: ## §1. Dynamic Layer Allocation] -/
theorem mod_saves_over_full (nt al fl lc : ℕ) (hal : al ≤ fl) :
    modCost nt al lc ≤ stdFullCost nt fl lc := by
  unfold modCost stdFullCost; gcongr

/-- [Section: ## §3. Compound Savings: MoD × EML] -/
theorem eml_mod_compound (nt al fl lc_eml lc_std : ℕ)
    (hal : al ≤ fl) (hlc : lc_eml ≤ lc_std) :
    modCost nt al lc_eml ≤ stdFullCost nt fl lc_std := by
  unfold modCost stdFullCost; gcongr

/-- [Section: ## §4. Token-Level Routing] -/
theorem fewer_routed_cheaper (t r1 r2 lc : ℕ) (hr : r1 ≤ r2) :
    modCost t r1 lc ≤ modCost t r2 lc := by
  unfold modCost; gcongr

/-- With capacity factor C < 1, only C fraction of tokens processed -/
def capacityCost (numTokens capacityPercent layerCost : ℕ) : ℕ :=
  numTokens * capacityPercent / 100 * layerCost

/-- [Section: ## §5. Layer Skip Patterns] -/
theorem lower_capacity_cheaper (nt c1 c2 lc : ℕ) (hc : c1 ≤ c2) :
    capacityCost nt c1 lc ≤ capacityCost nt c2 lc := by
  unfold capacityCost
  exact Nat.mul_le_mul_right lc (Nat.div_le_div_right (Nat.mul_le_mul_left nt hc))

/-- KV-cache memory: only allocated for active layers -/
def modKVCacheMemory (numTokens activeLayers d_model : ℕ) : ℕ :=
  numTokens * (activeLayers * (2 * d_model))

/-- [Section: ## §6. Memory Savings from Skipping] -/
theorem mod_kv_cache_saves (nt al fl dm : ℕ) (hal : al ≤ fl) :
    modKVCacheMemory nt al dm ≤ modKVCacheMemory nt fl dm := by
  unfold modKVCacheMemory; gcongr

/-- [Section: ## §7. Total MoD Pipeline] -/
def modTotalCost (routerCost layerCost numTokens avgActive : ℕ) : ℕ :=
  numTokens * routerCost + modCost numTokens avgActive layerCost

theorem eml_mod_total_cheaper (rc_eml rc_std lc_eml lc_std nt aa : ℕ)
    (hrc : rc_eml ≤ rc_std) (hlc : lc_eml ≤ lc_std) :
    modTotalCost rc_eml lc_eml nt aa ≤ modTotalCost rc_std lc_std nt aa := by
  unfold modTotalCost modCost
  have h1 : nt * rc_eml ≤ nt * rc_std := Nat.mul_le_mul_left nt hrc
  have h2 : aa * lc_eml ≤ aa * lc_std := Nat.mul_le_mul_left aa hlc
  have h3 : nt * (aa * lc_eml) ≤ nt * (aa * lc_std) := Nat.mul_le_mul_left nt h2
  omega

theorem eml_mod_router_savings (nL dm : ℕ) (hd : 4 ≤ dm) :
    emlRouterParams nL ≤ stdRouterParams dm nL := by
  exact eml_router_compact dm nL hd

end
