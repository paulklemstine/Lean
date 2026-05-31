def composition_robustness_radius(margin: float, lip_feature: float, lip_classifier: float) -> float:
    if margin <= 0 or lip_feature <= 0 or lip_classifier <= 0:
        return 0.0
    return margin / (lip_feature * lip_classifier)