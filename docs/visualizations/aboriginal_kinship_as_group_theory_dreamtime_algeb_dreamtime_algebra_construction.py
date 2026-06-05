class DreamtimeAlgebra:
    def __init__(self, n, marry_gen, descent_gen):
        self.n = n
        self.marry_gen = marry_gen
        self.descent_gen = descent_gen
    def marriage_map(self, g):
        return tuple((a+b)%2 for a,b in zip(g, self.marry_gen))
    def descent_map(self, g):
        return tuple((a+b)%2 for a,b in zip(g, self.descent_gen))