class MinPlusExpr:
    def eval(self, assignment):
        if self.kind == 'var': return assignment[self.var_idx]
        elif self.kind == 'const': return self.value
        elif self.kind == 'tmin': return min(self.left.eval(assignment), self.right.eval(assignment))
        elif self.kind == 'tplus': return self.left.eval(assignment) + self.right.eval(assignment)