import Markdown from 'react-markdown'
import blogContent from './assets/blog.md?raw'
import poster from './assets/img.png'
import { FaServer } from "react-icons/fa6";
import type { ReactNode, ElementType } from 'react';
import rehypeRaw from 'rehype-raw';

const NewTabA: ElementType = ({ href, children }: { href: string | undefined, children: ReactNode }) => {
  return (
    <a href={href} target="_blank" rel="noopener noreferrer">
      {children}
    </a>
  );
};

function App() {
  return (
    <div className="min-h-screen relative overflow-hidden bg-gradient-to-br from-red-50 via-orange-50 to-pink-50">
      <div className="absolute inset-0">
        <div className="absolute top-0 left-0 w-96 h-96 bg-gradient-to-br from-red-200/40 to-orange-200/40 rounded-full blur-3xl transform -translate-x-1/2 -translate-y-1/2"></div>
        <div className="absolute top-1/3 right-0 w-80 h-80 bg-gradient-to-bl from-pink-200/30 to-red-200/30 rounded-full blur-2xl transform translate-x-1/3"></div>
        <div className="absolute bottom-1/4 left-1/4 w-64 h-64 bg-gradient-to-tr from-orange-200/25 to-pink-200/25 rounded-full blur-xl"></div>
        <div className="absolute top-2/3 right-1/3 w-48 h-48 bg-gradient-to-l from-red-300/20 to-orange-300/20 rounded-full blur-2xl"></div>
      </div>

      <div className="relative z-10 min-h-screen flex items-center justify-center p-4 sm:p-6 lg:p-8">
        <article className="bg-white shadow-2xl shadow-red-500/35 max-w-4xl w-full mx-auto overflow-hidden">
          <div className="px-8 py-6 sm:p-12 lg:px-16 lg:py-10">

            {/*<div className="mb-10 p-3 bg-amber-50 border border-amber-200 rounded-lg">
              <div className="flex items-start gap-2">
                <svg className="w-4 h-4 text-amber-600 mt-0.5 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                  <path
                    fillRule="evenodd"
                    d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z"
                    clipRule="evenodd"
                  />
                </svg>
                <div>
                  <h3 className="text-sm font-semibold text-amber-800">Warning</h3>
                  <p className="text-xs text-amber-700 mt-1">
                    This article is NOT for vibe-coders. You guys wouldn't care.
                  </p>
                </div>
              </div>
            </div>*/}

            <div className="flex items-center gap-3 mb-6 md:justify-start justify-center">
              <div className="w-8 h-8 bg-gradient-to-r from-red-500 to-orange-400 rounded-lg flex items-center justify-center" >
                <FaServer color='white' />
              </div>
              <h1 className="text-2xl font-bold">
                <span className="text-gray-800">easy</span>
                <span className="text-red-400 font-light">BARE-METAL</span>
              </h1>
            </div>

            <img src={poster} alt='poster' className='rounded-md mb-5' />

            <div className="mb-8 pb-6 border-b border-gray-100">
              <div className="flex md:flex-row flex-col items-start gap-4 text-sm text-gray-600">
                <span className="flex items-center gap-2">
                  <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      fillRule="evenodd"
                      d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z"
                      clipRule="evenodd"
                    />
                  </svg>
                  June 28, 2025
                </span>
                <span className="flex items-center gap-2">
                  <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      fillRule="evenodd"
                      d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z"
                      clipRule="evenodd"
                    />
                  </svg>
                  8 min read
                </span>
                <div className="flex items-center gap-2">
                  <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      fillRule="evenodd"
                      d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z"
                      clipRule="evenodd"
                    />
                  </svg>
                  <span>By</span>
                  <div className="flex items-center gap-4">
                    {/* Author 1 */}
                    <div className="flex items-center gap-1.5">
                      <span className="font-medium">Adam Cholewiński</span>
                      <div className="flex items-center gap-1">
                        <a
                          href="https://github.com/adamchol"
                          className="text-gray-500 hover:text-gray-700 transition-colors"
                          target='_blank'
                          aria-label="Adam's GitHub"
                        >
                          <svg className="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
                          </svg>
                        </a>
                        <a
                          href="https://x.com/adamchol_"
                          className="text-gray-500 hover:text-gray-700 transition-colors"
                          target='_blank'
                          aria-label="Adam's X"
                        >
                          <svg className="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
                          </svg>
                        </a>
                      </div>
                    </div>

                    {/* Separator */}
                    <span className="text-gray-400">&</span>

                    {/* Author 2 */}
                    <div className="flex items-center gap-1.5">
                      <span className="font-medium">Patryk Wojnarowski</span>
                      <div className="flex items-center gap-1">
                        <a
                          href="https://github.com/plan9better"
                          className="text-gray-500 hover:text-gray-700 transition-colors"
                          target='_blank'
                          aria-label="Patryk's GitHub"
                        >
                          <svg className="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
                          </svg>
                        </a>
                        <a
                          href="https://x.com/plan9better"
                          className="text-gray-500 hover:text-gray-700 transition-colors"
                          target='_blank'
                          aria-label="Patryk's X"
                        >
                          <svg className="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
                          </svg>
                        </a>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="prose prose-h1:text-3xl prose-h1:lg:text-4xl">
              <Markdown rehypePlugins={[rehypeRaw]} components={{ a: NewTabA }}>{blogContent}</Markdown>
            </div>
          </div>
        </article>
      </div>
    </div>
  )
}

export default App
