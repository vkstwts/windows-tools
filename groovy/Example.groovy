class Speaker {
    String name;
    def age;
    String toString() {
        "My name is $name and I'm $age"
    }
}

def speakers = [
    new Speaker(name:"Prathap", age:33),
    new Speaker(name:"Raju", age:35),
    new Speaker(name:"Ranga", age:35),
    new Speaker(name:"Rahul", age:31)
]

def upper = { it.toString().toUpperCase() }
def lower = { it.toString().toLowerCase() }

speakers.findAll{name -> name = /.*Ra.*/ }
    .collect(upper).each{ println it}
speakers.findAll{name -> name = /.*thap./ }
    .collect(lower).each{ println it}