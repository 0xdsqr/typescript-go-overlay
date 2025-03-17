function greet(person) {
    return `Hello ${person.name}, you are ${person.age} years old!`;
}
const john = {
    name: "John",
    age: 30
};
console.log(greet(john));
