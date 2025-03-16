interface Person {
    name: string;
    age: number;
  }
  
  function greet(person: Person): string {
    return `Hello ${person.name}, you are ${person.age} years old!`;
  }
  
  const john: Person = {
    name: "John",
    age: 30
  };
  
  console.log(greet(john));