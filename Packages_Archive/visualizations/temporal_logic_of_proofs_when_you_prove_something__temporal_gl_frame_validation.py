from typing import Dict, List, Set, Tuple

World = int
Relation = Set[Tuple[World, World]]

def is_transitive(worlds: List[World], R: Relation) -> bool:
    return all((x, z) in R for x in worlds for y in worlds for z in worlds
               if (x, y) in R and (y, z) in R)

def is_reflexive(worlds: List[World], R: Relation) -> bool:
    return all((w, w) in R for w in worlds)

def is_converse_well_founded(worlds: List[World], R: Relation) -> bool:
    colour: Dict[World, int] = {w: 0 for w in worlds}
    def dfs(u: World) -> bool:
        colour[u] = 1
        for v in worlds:
            if (u, v) in R:
                if colour[v] == 1:
                    return False
                if colour[v] == 0 and not dfs(v):
                    return False
        colour[u] = 2
        return True
    return all(colour[w] != 0 or dfs(w) for w in worlds)

def satisfies_compat(worlds: List[World], R: Relation, T: Relation) -> bool:
    return all((w, v) in R for w in worlds for wp in worlds for v in worlds
               if (w, wp) in T and (wp, v) in R)

def validate(worlds: List[World], R: Relation,
             T: Relation) -> Dict[str, bool]:
    return {
        "R_transitive": is_transitive(worlds, R),
        "R_converse_well_founded": is_converse_well_founded(worlds, R),
        "T_reflexive": is_reflexive(worlds, T),
        "T_transitive": is_transitive(worlds, T),
        "compat": satisfies_compat(worlds, R, T),
    }
