class employee:
    def __init__(self,name, salary):
        self.name = name
        self.salary = salary

    def getsalary(self):
        print(self.salary)

person1 = employee("pratik", "100000")
# print(person1.name)
# print(person1.salary)
person1.getsalary()