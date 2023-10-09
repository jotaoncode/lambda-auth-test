const responseFormatted = (statusCode: number, message: string) => ({
  statusCode,
    headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    message,
  }),
});

export {
  responseFormatted
}