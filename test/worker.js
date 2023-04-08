class Person {
	constructor(name) {
		this.name = name;
		this.job = null
	}
	sayName() {
		console.log(this.name);
	}
	setJob(job) {
		this.job = job;
		return this
	}
}

class Worker extends Person {
	constructor(name, job, employer) {
		super(name);
		this.job = job;
		this.employer = employer
	}
	sayOccupation() {
		console.log(`I am a ${this.job} at ${this.employer}`)
	}
}

export const newWorkerImpl = (a, b, c) =>
	new Worker(a, b, c);

export const employerImpl = obj => obj.employer;

export const sayOccupationImpl = (obj) => obj.sayOccupation();
