import * as crypto from 'crypto';

const encrypt = (text: string, encryptCode: string): string => {
  let iv = crypto.randomBytes(16);
  let salt = crypto.randomBytes(16);
  let key = crypto.scryptSync(encryptCode, salt, 32);

  let cipher = crypto.createCipheriv('aes-256-cbc', key, iv);
  let encrypted = cipher.update(text, "utf8", "hex");
  encrypted += cipher.final("hex");

  return `${iv.toString("hex")}:${salt.toString("hex")}:${encrypted}`;

}

const decrypt = (text: string, encryptCode: string): string => {
  let [ivs, salts, data] = text.split(":");
  let iv = Buffer.from(ivs, "hex");
  let salt = Buffer.from(salts, "hex");
  let key = crypto.scryptSync(encryptCode, salt, 32);
  let decipher = crypto.createDecipheriv('aes-256-cbc', key, iv);
  let decrypted = decipher.update(data, "hex", "utf8");
  decrypted += decipher.final("utf8");

  return decrypted.toString();
}

export {
  encrypt,
  decrypt
}