def nearest_recipe_additive(target, fmap):
    recipe = []
    for i in range(fmap.n):
        best = min(range(fmap.m), key=lambda v: np.linalg.norm(fmap.contrib[i][v] - target/fmap.n))
        recipe.append(best)
    return tuple(recipe)