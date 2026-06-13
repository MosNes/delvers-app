import { withSupabase } from 'npm:@supabase/server@^1'

console.log('Hello from Cloudflare Turnstile!')

function ips(req: Request) {
  return req.headers.get('x-forwarded-for')?.split(/\s*,\s*/)
}

export default {
  fetch: withSupabase({ auth: 'none' }, async (req) => {
    const { token } = await req.json()
    const clientIps = ips(req) || ['']
    const ip = clientIps[0]

    let formData = new FormData()
    formData.append('secret', Deno.env.get('CLOUDFLARE_SECRET_KEY') ?? '')
    formData.append('response', token)
    formData.append('remoteip', ip)

    const url = 'https://challenges.cloudflare.com/turnstile/v0/siteverify'
    const result = await fetch(url, {
      body: formData,
      method: 'POST',
    })

    const outcome = await result.json()
    if (outcome.success) {
      return new Response('success')
    }
    return new Response('failure')
  }),
}
