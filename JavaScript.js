//1.
let salaries = {
    John: 100,
    Ann: 160,
    Pete: 130
};

console.log(salaries);

function sumAll(obj) {
    let sum = 0;
    for ( x in obj) {
        sum += obj[x];
    }
    return sum;
};

console.log(sumAll(salaries));

//2.
let menu = {
    width: 200,
    height: 300,
    title: "My menu"
};

function multiplyNumeric(obj){
    for (x in obj) {
        if ((typeof obj[x]) == 'number') {
            obj[x] = obj[x] * 2;
        }
    }
};

multiplyNumeric(menu);
console.log(menu);

//3.
function checkEmailId(str) {
    if (str.includes("@") && str.includes(".")) {
        let p1 = str.indexOf("@");
        let p2 = str.indexOf(".");
        if ((p1 < p2) && (p2 - p1 > 1)){
            return true;
        }
    }
    return false;
}

console.log(checkEmailId("abcd@ef.g"));

//4.
function truncate(str, maxlength){

    let length = str.length;

    if (length <= maxlength) {
        return str;
    }

    str = str.slice(0, maxlength - 1);
    return str + "…"
}

console.log(truncate("Hi everyone!", 20));

//5.
let names = ["James", "Brennie"];
names.push("Robert");
if (names.length/2 != 0) {
    names[names.length / 2 - .5] = "Calvin";
}

console.log(names.shift());

names.unshift("Rose", "Regal");

console.log(names);

//6.
function validateCards(cardsToValidate, bannedPrefixes) {

    let status = {
        Card : cardsToValidate,
        isValid : false,
        isAllowed : true
    };

    let cardLength = cardsToValidate.length;
    let sum = 0;

    for (var i = 0; i < cardLength - 1; i++) {
        sum += cardsToValidate[i] * 2;
    }

    if (sum % 10 == cardsToValidate[cardLength - 1]) {
        status.isValid = true;
    }

    bannedPrefixes = bannedPrefixes.replace(/\s+/g, "");
    let inValidPre = bannedPrefixes.split(",");

    inValidPre.forEach(function (pre) {

        if (cardsToValidate.startsWith(pre)) {
            status.isAllowed = false;
        }
    })

    return JSON.stringify(status);
}

console.log(validateCards("6724843711060148", "11, 3434, 67453, 9, 67 "));