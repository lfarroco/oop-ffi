class Person {
	constructor(name, age) {
		this.name = name;
		this.age = age
	}
	sayName() {
		console.log(`My name is ${this.name}`)
	}
	setAge(n) {
		this.age = n
		return this
	}
}

class Employee extends Person {
	constructor(name, age, employer) {
		super(name, age);
		this.employer = employer;
		this.room = null
	}
	sayEmployer() {
		console.log(`I work at ${this.employer}`)
	}
	setRoom(room) {
		this.room = room
		return this;
	}
}

export const expose = () => {
	global.Person = Person
	global.Employee = Employee
}
