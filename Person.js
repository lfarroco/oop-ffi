export const newPersonImpl = (a, b) =>
  new Person(a, b);

export const nameImpl = obj => obj.name;

export const ageImpl = obj => obj.age;

export const sayNameImpl = (obj) => obj.sayName();

export const setAgeImpl = (a, obj) => obj.setAge(a);
