export default class Person {
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
export const newPersonImpl = (string) =>
	new Person(string);

export const nameImpl = obj => obj.name;

export const jobImpl = obj => obj.job;

export const setJobImpl = (a, obj) => obj.setJob(a);

export const sayNameImpl = (obj) => obj.sayName();